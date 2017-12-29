module UserRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.namespace('/api') {|c|
        c.get('/roles') {
          make_default_json_api(self) {
            Role.list_roles
          }
        }

        c.post('/users') {
          make_default_json_api(self, @request_payload) {|params, _status_code|
            {status: _status_code, response: User.save_or_update_user(params)}
          }
        }

        c.post('/users/find') {
          make_default_json_api(self, @request_payload) {|params, _status_code|
            {status: _status_code, response: User.find_user(params)}
          }
        }

        c.delete('/users/:usuario_id') {|usuario_id|
          make_default_json_api(self) {
            raise UnexpectedParamException.new "Parâmetro de URL inesperado #{usuario_id}" unless usuario_id.match(/^\d+$/)

            User.disable_user(usuario_id)
          }
        }

        c.get('/users/disabled-list') {
          make_default_json_api(self) {
            User.list_disabled_users
          }
        }

        c.get('/user/:usuario_id') {|usuario_id|
          make_default_json_api(self) {
            raise UnexpectedParamException.new "Parâmetro de URL inesperado #{usuario_id}" unless usuario_id.match(/^\d+$/)

            User.get_user_by_id(usuario_id)
          }
        }

        c.post('/user/change-password') {
          make_default_json_api(self, @request_payload) {|params, _status_code|

            user_token = ApiAuther.identify(@request_token)

            user = User.get_user_by_id_as_object(user_token[:user_id])

            user = User.change_password(params, @request_token, user) if user

            out = {mensagem: 'Senha alterada com sucesso.'} if user

            params[:email] = user[:email]

            out ||= {mensagem: 'Não foi possível alterar a senha'}

            {status: _status_code, response: out}
          }
        }

        c.post('/users/list') {
          make_default_json_api(self, @request_payload) {|params, _status_code|
            {status: _status_code, response: User.list_users_with_pagination(params)}
          }
        }
      }
    end
  end
end
