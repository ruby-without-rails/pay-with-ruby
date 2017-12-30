module RoleRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper
      controller.include PayWithRuby::Helpers::ApiValidation

      controller.namespace('/api') do |c|

        c.get('/roles') do
          make_default_json_api(self) do
            Role.list_roles
          end
        end

        c.post('/role') do
          make_default_json_api(self)
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