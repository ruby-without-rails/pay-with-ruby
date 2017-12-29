module AuthenticationRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.namespace('/api') do |c|
        c.post('/login') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            user = User.login_user(params)

            if user
              _status_code = 200
              user_token = UserToken.save_user_token(user[:id])
              body = { token: user_token.token }
            else
              _status_code = 400
              body = { mensagem: 'Login ou senha inválidos' }
            end

            { status: _status_code, response: body }
          end
        end

        c.get('/logout') do
          make_default_json_api(self) do
            ApiAuther.unauthorize_or_raise(@request_token)
          end
        end

        c.get('/get_user_data') do
          make_default_json_api(self) do
            user_token = ApiAuther.identify(@request_token)
            user = User.get_user_by_id(user_token.usuario_id)
            { user: user }
          end
        end
      end
    end
  end
end
