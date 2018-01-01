module CustomerRoutes
  class << self
    def extended(controller)
      controller.namespace('/api') do |c|

        c.get('/customers') do
          make_default_json_api(self) do
            validate_access(@request_token, 'Administrador')
            Customer.list_customers
          end
        end

        c.post('/customer') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            {status: _status_code, response: Customer.save_customer(params)}
          end
        end

        c.delete('/customer/:customer_id') do |customer_id|
          make_default_json_api(self) do
            raise UnexpectedParamException, "Parâmetro de URL inesperado #{customer_id}" unless customer_id =~ /^\d+$/
            validate_access(@request_token, 'Administrador')
            Customer.delete_customer(customer_id)
          end
        end

        c.get('/customer/:customer_id') do |customer_id|
          make_default_json_api(self) do
            raise UnexpectedParamException, "Parâmetro de URL inesperado #{customer_id}" unless customer_id =~ /^\d+$/
            validate_access(@request_token, 'Administrador')
            Customer.get_customer_by_id(customer_id)
          end
        end
      end
    end
  end
end

