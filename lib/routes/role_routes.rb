module RoleRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper::ApiBuilder
      controller.include PayWithRuby::Helpers::ApiHelper::ApiValidation
      controller.include PayWithRuby::Helpers::ApiHelper::ApiAccess

      controller.namespace('/api') do |c|

        c.get('/roles') do
          make_default_json_api(self) do
            Role.list_roles
          end
        end

        c.post('/role') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            validate_access(@request_token, 'Admin')
            validate_params(params, %i[code description])
            {status: _status_code, response: Role.save_role(params)}
          end
        end

        c.get('/role/:role_id') do |role_id|
          make_default_json_api(self) do
            Role.get_role_by_id(role_id)
          end
        end

        c.delete('/role/:role_id') do |role_id|
          make_default_json_api(self) do
            Role.delete_role(role_id)
          end
        end
      end
    end
  end
end