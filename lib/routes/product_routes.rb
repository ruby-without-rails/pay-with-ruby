module ProductRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper
      controller.include PayWithRuby::Helpers::ApiValidation

      controller.namespace('/api') do |c|

        c.get('/products') do
          make_default_json_api(self) do
            Product.list_products
          end
        end

        c.post('/product') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            validate_params(params, %i[name description category])
            {status: _status_code, response: Product.save_product(params)}
          end
        end

        c.delete('/product/:product_id') do |product_id|
          make_default_json_api(self) do
            raise UnexpectedParamException, "Parâmetro de URL inesperado #{product_id}" unless product_id =~ /^\d+$/

            Product.delete_product(product_id)
          end
        end

        c.get('/product/:product_id') do |product_id|
          make_default_json_api(self) do
            raise UnexpectedParamException, "Parâmetro de URL inesperado #{product_id}" unless product_id =~ /^\d+$/

            Product.get_product_by_id(product_id)
          end
        end
      end
    end
  end
end
