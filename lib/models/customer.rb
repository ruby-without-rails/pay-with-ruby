require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module CustomerModule

      class Customer < BaseModel

        # Set Customer dataset:
        set_dataset DB[:customers]

        # Set primary key and relationships:
        set_primary_key :id

        # def initialize; end

        def validate
          super
          errors = []
          errors << ({field: 'name', error: 'cannot be null'}) if name.nil?
          errors << ({field: 'name', error: 'must be a String'}) if name and name.match?(/\d/)
          errors << ({field: 'name', error: 'cannot be empty'}) if name and not name.match?(/\d/) and name.empty?
          errors << ({field: 'name', error: 'must be have 6 characters'}) if name and not name.match?(/\d/) and name.size < 6

          errors << ({field: 'cpf', error: 'cannot be null'}) if cpf.nil?
          errors << ({field: 'cpf', error: 'must be a String'}) if cpf and not cpf.match?(/\w/)
          errors << ({field: 'cpf', error: 'cannot be empty'}) if cpf and not cpf.match?(/\d/) and cpf.empty?

          errors << ({field: 'email', error: 'cannot be null'}) if email.nil?
          errors << ({field: 'email', error: 'must be a String'}) if email and email.match?(/\d/)
          errors << ({field: 'email', error: 'cannot be empty'}) if email and not email.match?(/\d/) and email.empty?
          errors << ({field: 'email', error: 'must be have 6 characters'}) if email and not email.match?(/\d/) and email.size < 6

          errors << ({field: 'fcm_id', error: 'cannot be null'}) if fcm_id.nil?
          # errors << ({field: 'fcm_id',error: 'must be a String'}) if fcm_id and fcm_id.match?(/\d/)
          errors << ({field: 'fcm_id', error: 'cannot be empty'}) if fcm_id and not fcm_id.match?(/\d/) and fcm_id.empty?
          errors << ({field: 'fcm_id', error: 'must be have 6 characters'}) if fcm_id and not fcm_id.match?(/\d/) and fcm_id.size < 6
        end

        def after_save
          access_token = AccessToken.save_access_token({}, self, 'created-from-server')
          self.values[:access_token] = {key: access_token[:key], expires_at: access_token[:expires_at]}
        end

        class << self
          def save_customer(customer_data, request_token)
            id = customer_data[:id]

            if not id.nil? and id.to_s.match?(/\d/)
              # TODO - identify and authorize only admins to create/update customers, and the owner of customer to update self
              access_token = ApiAuther.identify(request_token) if request_token and id
              raise ModelException.new 'Você precisa de um token para atualizar o Cliente.' unless access_token

              old_customer = access_token.customer
              raise ModelException.new 'Não foi encontrado um Cliente para este Token' unless old_customer

              customer = Customer[id]
              raise ModelException.new "Cliente não encontrado com o id #{id}" unless customer

              raise ModelException.new 'Somente o própio cliente ou Administrador podem atualizar os dados.' if customer[:id] != old_customer[:id] or !access_token.user.nil?

            else
              customer = Customer.new
            end

            customer.name = customer_data[:name]
            customer.cpf = customer_data[:cpf]
            customer.email = customer_data[:email]
            customer.fcm_id = customer_data[:fcm_id]
            customer.fcm_message_token = customer_data[:fcm_message_token]
            customer.mobile_phone_number = customer_data[:mobile_phone_number]


            if customer.valid?
              message = customer.exists? ? 'Cliente foi atualizado com sucesso!' : 'Cliente foi salvo com sucesso!'
              customer.save

              token = customer[:access_token]
              customer_hash = customer.values
              customer_hash.delete(:access_token)

              {customer: customer_hash, token: token, message: message}
            else
              {validation_errors: customer.errors}
            end
          end

          def get_customer_by_id(customer_id, for_api = true)
            customer = Customer[customer_id]
            if for_api
              {customer: customer.nil? ? {} : customer.values}
            else
              customer
            end
          end

          def get_customer_by_name(customer_name, for_api = true)
            customer = Customer.where(name: customer_name).first

            if for_api
              {customer: customer.nil? ? {} : customer.values}
            else
              customer
            end
          end

          def get_customer_by_cpf(customer_cpf, for_api = true)
            customer = Customer.where(cpf: customer_cpf).first

            if for_api
              {customer: customer.nil? ? {} : customer.values}
            else
              customer
            end
          end

          def get_customer_by_fcm_id(customer_fcm_id, for_api = true)
            customer = Customer.where(fcm_id: customer_fcm_id).first

            if for_api
              {customer: customer.nil? ? {} : customer.values}
            else
              customer
            end
          end

          def list_customers
            {customers: Customer.all.map(&:values)}
          end

          def delete_customer(customer_id)
            customer = Customer[customer_id]
            customer.delete if customer

            msg = customer.nil? ? "Cliente com o id: #{customer_id} não encontrado" : "Cliente com id: #{customer_id} excluído com sucesso"

            {msg: msg}
          end

          def login_customer(login_data)
            DB[:customers].select(:id, :name, :cpf, :email, :fcm_id, :created_at)
                .where(fcm_id: login_data[:fcm_id], deleted_at: nil).first
          end
        end
      end
    end
  end
end
