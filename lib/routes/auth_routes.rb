module AuthRoutes
  class << self
    def extended(controller)
      controller.namespace('/api') do |c|
        c.namespace('/auth') do |c|

          c.post('/login') do
            make_default_json_api(self, @request_payload) do |params, _status_code|
              user = User.login_user(params) if params.key?(:email) and params.key?(:password)
              customer = Customer.login_customer(params) if params.key?(:fcm_id)

              halt 400 , JSON.generate({msg: 'Incorret Request params.'}) if user and customer

              if user or customer
                _status_code = 200
                user = user.nil? ? {} : user
                customer = customer.nil? ? {} : customer

                ApiAuther.clean_old_tokens(user, customer)
                access_token = AccessToken.save_access_token(user, customer, @request_ip)
                body = {token: access_token.key, expires_at: access_token.expires_at}
              else
                _status_code = 400
                body = {mensagem: 'Login , senha ou fcm_id inválidos'}
              end

              {status: _status_code, response: body}
            end
          end

          c.get('/logout') do
            make_default_json_api(self) do
              ApiAuther.unauthorize_or_raise(@request_token)
            end
          end

          c.get('/user_data') do
            make_default_json_api(self) do
              access_token = ApiAuther.identify(@request_token)
              if access_token.user
                User.get_user_by_id(access_token.user_id)
              else
                Customer.get_customer_by_id(access_token.customer_id)
              end
            end
          end
        end
      end
    end
  end
end
