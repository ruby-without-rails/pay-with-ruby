module PaymentRoutes
  class << self
    def extended(controller)
      controller.namespace('/mundipagg') do |c|
        c.post('/credit-card') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            validate_params(params, %i[order_id selected_payment total])
            payment_data = Payment.generate_payment_data(params, @request_token, @request_url)
            {status: _status_code, response: CreditCard.pay(payment_data)}
          end
        end
      end
    end
  end
end