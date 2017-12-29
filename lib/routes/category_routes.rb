module CategoryRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.namespace('/api') do |c|
        c.get('/categories') do
          make_default_json_api(self) do
            Category.list_categories
          end
        end

        c.post('/categories') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            {status: _status_code, response: Category.save_category(params)}
          end
        end

        c.delete('/category/:category_id') do |category_id|
          make_default_json_api(self) do
            raise UnexpectedParamException, "Parâmetro de URL inesperado #{category_id}" unless category_id =~ /^\d+$/

            Category.delete_category(category_id)
          end
        end

        c.get('/category/:category_id') do |category_id|
          make_default_json_api(self) do
            raise UnexpectedParamException, "Parâmetro de URL inesperado #{category_id}" unless category_id =~ /^\d+$/

            Category.get_category_by_id(category_id)
          end
        end
      end
    end
  end
end
