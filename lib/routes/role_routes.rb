module RoleRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.namespace('/api') do |c|

        c.get('/roles') do
          make_default_json_api(self) do
            Role.list_roles
          end
        end
      end
    end
  end
end
