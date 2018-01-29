# General requires:
require 'net/http'
require 'uri'
require 'nokogiri'

# MundiPag SDK
require 'mundipagg_sdk'
require 'requires'

module PayWithRuby
  module Gateways
    module Payment
      module MundiPagg
        # @class [Payment]
        class Payment < IntegrationModel
          class << self
            def generate_payment_data(body_params, request_token, request_url)
              access_token = ApiAuther.identify(request_token)
              buyer = access_token.customer

              buyer ||= body_params[:buyer]
              raise ModelException.new 'Cliente não encontrado.' unless buyer

              order = Order.get_order_by_id(body_params[:order_id], false)
              raise ModelException.new 'Pedido não encontrado.' unless order

              {
                  buyer: buyer,
                  total: body_params[:total],
                  selected_payment: body_params[:selected_payment],
                  order: order,
                  request_url: request_url
              }
            end
          end
        end

        # @class [OnlineDebitTransaction]
        class OnlineDebitTransaction < IntegrationModel
          class << self

            # Realiza Pagamento com Transferência Bancária
            # return response
            def pay(payment_data)
              buyer = payment_data[:buyer]
              selected_payment = payment_data[:selected_payment]
              payment_data[:installments] = 1

              DB.transaction(rollback: :reraise) do

                merchant_key = StartupConfig.merchant_key_mundipagg
                webhook = "#{payment_data[:request_url]}/api/webhooks/mundipagg"

                payload = {
                    Buyer: {
                        Name: buyer[:name]
                    },
                    OnlineDebitTransaction:
                        {
                            # Valor da transação em centavos. R$ 100,00 = 10000
                            AmountInCents: (payment_data[:total] * 100).round(0),
                            Bank: selected_payment[:bank],
                            Options: {
                                NotificationUrl: webhook
                            }
                        },
                    Order: {
                        OrderReference: payment_data[:order][:id]
                    }
                }.to_json

                headers = {'MerchantKey': merchant_key, content_type: :json}

                return_data = send_post_rest_client("#{StartupConfig.base_url_mundipagg}/Sale", payload, headers)

                if return_data[:sucesso]

                else

                end

                return_data
              end
            end

            def process_callback(params, request_url)
              if params[:StatusNotification]
                notification = params[:StatusNotification]
              else
                return nil
              end

              transaction = notification[:OnlineDebitTransaction]

              order_reference = notification[:OrderReference]

              if notification[:OrderStatus].eql?('Paid')

                # Valor da transação em centavos. R$ 100,00 = 10000
                received_value = transaction[:AmountPaidInCents].to_f / 100

                order = Order.get_order_by_id(order_reference)
                raise ModelException.new 'Pedido não encontrado.' unless order

                # dar baixa no pedido
                if received_value >= order[:total]


                end
              end
            end

            private

            def persistent_post(url, payload, headers, max_attempts)
              found = false
              attempts = 0
              until found || attempts >= max_attempts
                attempts += 1
                http = Net::HTTP.new(url.host, url.port)
                http.open_timeout = 10
                http.read_timeout = 40
                path = url.path
                path = '/' if path == ''

                req = Net::HTTP::Post.new(path, headers)

                resp = http.request(req, payload)

                break if resp.code.eql?('200')

                if !resp.header['location'].nil?
                  newurl = URI.parse(resp.header['location'])
                  if newurl.relative?
                    puts 'url was relative'
                    newurl = url + resp.header['location']
                  end
                  url = newurl
                else
                  found = true
                end
              end
            end

            def send_post_rest_client(uri_str, payload, headers)
              begin
                return_data = RestClient.post(uri_str, payload, headers)
              rescue RestClient::MovedPermanently,
                  RestClient::Found,
                  RestClient::TemporaryRedirect, RestClient::Redirect => err
                begin
                  return_data = err.response.follow_redirection
                rescue RestClient::ExceptionWithResponse => err
                  return_data = err.response
                end
              end

              case return_data.code
                when 200, 201 then
                  parsed_response = parse_xml(return_data)
                else
                  raise ModelException.new 'Não foi possível concluir o pagamento com transferência eletrônica. Contate o Administrador do sistema.'
                # TODO - enviar para o logger.
              end
              parsed_response
            end

            def parse_xml(xml_str)
              doc = Nokogiri::XML(xml_str)
              debit_transaction_result = doc.at_xpath('//OnlineDebitTransactionResult')
              order_result = doc.at_xpath('//OrderResult')
              request_key = doc.at_xpath('//RequestKey')

              {
                  data_hora_criacao: Date.parse(order_result.xpath('CreateDate').text),
                  chave_pedido: order_result.xpath('OrderKey').text,
                  chave_solicitacao: request_key.text,
                  sucesso: (debit_transaction_result.xpath('Success').text).eql?('true'),
                  referencia_venda: order_result.xpath('OrderReference').text,
                  transferencia_eletronica: {
                      # Valor da transação em centavos. R$ 100,00 = 10000
                      valor: (debit_transaction_result.xpath('AmountInCents').text).to_f / 100,
                      status: debit_transaction_result.xpath('OnlineDebitTransactionStatus').text,
                      url_pagamento: debit_transaction_result.xpath('PaymentUrl').text,
                      chave_transacao: debit_transaction_result.xpath('TransactionKey').text,
                      codigo_banco: debit_transaction_result.xpath('TransactionKeyToBank').text,
                  }
              }
            end

            def send_post_recursive(uri_str, payload, headers, limit = -1)
              # You should choose a better exception.
              raise ArgumentError, 'too many HTTP redirects' if limit == 0

              response = Net::HTTP.post(URI(uri_str), payload, headers)

              case response
                when Net::HTTPSuccess then
                  response
                when Net::HTTPRedirection then
                  location = response['location']
                  warn "redirected to #{location}"
                  send_post_recursive(URI(location), payload, headers, limit)
                when Net::HTTPBadRequest then
                  response
                else
                  response.value
              end
            end
          end
        end

        # @class [CreditCard]
        class CreditCard < IntegrationModel
          extend CodeCode::Common::Utils::Hash

          class << self

            def pay(payment_data)
              DB.transaction(rollback: :reraise) do
                begin
                  response = pay_with_credit_card(payment_data)
                  symbolize_keys!(response)

                rescue StandardError => e
                  payment_data[:mensagem] = 'Erro de Processamento de Pagamento.'
                  raise ModelException, 'Não foi possível realizar pagamento com Mundipagg. Contate o Administrador do Sistema.'
                end

                credit_card_transaction = response[:CreditCardTransactionResultCollection]

                success = false, authorization_code = nil

                errors = []

                total = 0
                transaction_id = ""

                if credit_card_transaction
                  credit_card_transaction.each do |t|
                    symbolize_keys!(t)
                    transaction_id = t[:TransactionIdentifier]
                    success = t[:Success]
                    authorization_code = t[:AuthorizationCode]
                    total = t[:AmountInCents]
                  end
                else
                  item_collection = response[:ErrorReport][:ErrorItemCollection].each do |i|
                    symbolize_keys!(i)
                    errors << i[:Description]
                  end
                end

                if success
                  data = {
                      authorization_code: authorization_code,
                      transaction_id: transaction_id,
                      success: success,
                      order_result: response[:OrderResult],
                      total: total
                  }


                else
                  mensagens = []

                  errors.each do |e|
                    mensagem = {msg: e}
                    mensagens << mensagem
                  end

                  data = {errors: mensagens}

                  payment_data[:mensagem] = 'Erro de Processamento de Pagamento.'

                  exception = ModelException.new('Erro de Processamento de Pagamento com Cartão.', 400, 0, data)

                end

                # 'Paliativo' SandBox - Insere Mensagem de Erro quando valor for Superior ao Permitido no SandBox
                if data[:errors] && data[:errors].empty?
                  if StartupConfig.environment == :develop
                    data[:errors] << {msg: "#{credit_card_transaction.first[:AcquirerMessage]} \n Valor superior ao permitido em ambiente Sandbox > 1030,00"}
                  else
                    data[:errors] << {msg: "Não foi possível realizar o pagamento. \n Entre em contato com o suporte informando o seguinte erro: \n
                    #{credit_card_transaction.first[:AcquirerMessage]}"}
                  end

                  payment_data[:mensagem] = 'Erro de Processamento de Pagamento.'

                  exception = ModelException.new('Erro de Processamento de Pagamento com Cartão.', 400, 0, data)
                end

                data
              end
            end

            private

            # Realiza Pagamento com Cartão de Crédito
            # @param reference_id [String] Identificador do pedido na sua base
            # return response
            def pay_with_credit_card(payment_data)
              merchant_key = StartupConfig.merchant_key_mundipagg

              # Send Transaction
              # instantiate class with request methods
              # :sandbox for sandbox ambient
              # :production for production ambient
              if StartupConfig.environment.eql?(:prod)
                gateway = Gateway::Gateway.new(:production, merchant_key)
              else
                gateway = Gateway::Gateway.new(:sandbox, merchant_key)
              end

              # create credit card transaction object
              credit_card_transaction = Gateway::CreditCardTransaction.new

              total = payment_data[:total]
              credit_card_info = payment_data[:selected_payment]
              reference_id = payment_data[:order][:id]

              # Valor da transação em centavos. R$ 100,00 = 10000
              credit_card_transaction.AmountInCents = (total * 100).round(0)
              credit_card_transaction.CreditCard.CreditCardBrand = credit_card_info[:card_brand]
              credit_card_transaction.CreditCard.CreditCardNumber = credit_card_info[:card_number]
              credit_card_transaction.CreditCard.ExpMonth = credit_card_info[:exp_month]
              credit_card_transaction.CreditCard.ExpYear = credit_card_info[:exp_year]
              credit_card_transaction.CreditCard.HolderName = credit_card_info[:holder_name]
              credit_card_transaction.CreditCard.SecurityCode = credit_card_info[:cvv]
              credit_card_transaction.InstallmentCount = credit_card_info[:installments]

              # creates request object for transaction creation
              create_sale_request = Gateway::CreateSaleRequest.new
              create_sale_request.CreditCardTransactionCollection << credit_card_transaction
              create_sale_request.Order.OrderReference = reference_id
              create_sale_request.ShoppingCartCollection = Order[reference_id].json_cart['products']

              # make the request and returns a response hash
              gateway.CreateSale(create_sale_request)
            end
          end
        end
      end
    end
  end
end