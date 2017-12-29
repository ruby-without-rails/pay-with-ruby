module AuthenticationRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.namespace('/api') {|c|
        c.post('/login') {
          make_default_json_api(self, @request_payload) {|params, _status_code|

            user = User.login_user(params)

            if user
              _status_code = 200
              user_token = UserToken.save_user_token(user[:id])
              body = {token: user_token.token}
            else
              _status_code = 400
              body = {mensagem: 'Login ou senha inválidos'}
            end

            {status: _status_code, response: body}
          }
        }

        c.get('/logout') {
          make_default_json_api(self) {
            ApiAuther.unauthorize_or_raise(@request_token)
          }
        }

        c.get('/get_user_data') {
          make_default_json_api(self) {
            user_token = ApiAuther.identify(@request_token)
            user = User.get_user_by_id(user_token.usuario_id)
            {user: user}
          }

        }
      }
    end
  end
end