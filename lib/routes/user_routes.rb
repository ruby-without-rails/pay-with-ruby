module UserRoutes
  class << self
    def extended(controller)
      controller.include PayWithRuby::Helpers::ApiHelper

      controller.namespace('/api') do |c|

        c.post('/users') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            {status: _status_code, response: User.save_or_update_user(params)}
          end
        end

        c.post('/users/find') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            {status: _status_code, response: User.find_user(params)}
          end
        end

        c.delete('/users/:user_id') do |user_id|
          make_default_json_api(self) do
            raise UnexpectedParamException, "Parâmetro de URL inesperado #{user_id}" unless user_id =~ /^\d+$/

            User.disable_user(user_id)
          end
        end

        c.get('/users/list-disabled') do
          make_default_json_api(self) do
            User.list_disabled_users
          end
        end

        c.get('/user/:user_id') do |user_id|
          make_default_json_api(self) do
            raise UnexpectedParamException, "Parâmetro de URL inesperado #{user_id}" unless user_id =~ /^\d+$/

            User.get_user_by_id(user_id)
          end
        end

        c.post('/user/change-password') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            user_token = ApiAuther.identify(@request_token)

            user = User.get_user_by_id_as_object(user_token[:user_id])

            user = User.change_password(params, @request_token, user) if user

            out = {mensagem: 'Senha alterada com sucesso.'} if user

            params[:email] = user[:email]

            out ||= {mensagem: 'Não foi possível alterar a senha'}

            {status: _status_code, response: out}
          end
        end

        c.post('/users/list') do
          make_default_json_api(self, @request_payload) do |params, _status_code|
            {status: _status_code, response: User.list_users_with_pagination(params)}
          end
        end
      end
    end
  end
end
