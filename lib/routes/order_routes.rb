module OrderRoutes
  class << self
    def extended(controller)
      controller.namespace('/api') do |c|

        c.get('/orders') do
          make_default_json_api(self) do
            Order.list_orders
          end
        end

        c.post('/order') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            validate_access(@request_token, 'Admin')
            validate_params(params, %i[code description])
            {status: _status_code, response: Order.save_order(params)}
          end
        end

        c.get('/order/:order_id') do |order_id|
          make_default_json_api(self) do
            Order.get_order_by_id(order_id)
          end
        end

        c.delete('/order/:order_id') do |order_id|
          make_default_json_api(self) do
            Order.cancel_order(order_id)
          end
        end
      end
    end
  end
end