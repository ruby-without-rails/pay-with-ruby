require 'requires'
require 'digest/sha1'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module UserModule

      # @class [User]
      class User < BaseModel
        include CodeCode::Common::Utils::Hash

        # Set User dataset:
        set_dataset DB[:users]

        # Set primary key and relationships:
        set_primary_key :id
        many_to_one(:roles, class: 'PayWithRuby::Models::UserModule::Role', key: :role_id)

        # def initialize; end

        def before_save
          super
          update_query_name(self)
        end

        def update_query_name(user_instance)
          user_instance[:query_name] = StringUtils.remove_accents(user_instance[:name].downcase)
        end

        class << self
          def save_user(user_data)
            symbolize_keys!(user_data)

            role = Role.get_role_by_code(user_data[:role])
            raise ModelException, 'O codigo do perfil é obrigatório.' unless role

            origin_passwd = user_data[:password].empty? ? TokenUtils.gerar_numeros_letras_minusculas(6) : user_data[:password]

            crypted_password = Digest::SHA1.hexdigest(origin_passwd)

            usuario = User.new
            usuario.name = user_data[:name]
            usuario.cpf = user_data[:cpf]
            usuario.email = user_data[:email]
            usuario.password = crypted_password
            usuario.role_id = role.id
            usuario.created_at = Time.now

            usuario.save

            user_data[:id] = usuario.id

            user_data
          end

          def update_user(user_data)
            symbolize_keys!(user_data)

            user = User.where(id: user_data[:id]).first
            raise ModelException, 'Impossível de atualizar, usuário inexistente no banco de dados.' unless user

            role = Role.get_role_by_code(user_data[:role])
            raise ModelException, 'O codigo do perfil é obrigatório.' unless role

            user.update(cpf: user_data[:cpf], name: user_data[:name],
                        email: user_data[:email], role_id: role[:id],
                        query_name: StringUtils.remove_accents(user_data[:name].downcase))

            user.update(password: Digest::SHA1.hexdigest(user_data[:password])) if user_data[:password]

            user
          end

          def save_or_update_user(body_params)
            if body_params[:id].nil? || body_params[:id].zero? || body_params[:id].empty?
              user = User.save_user(body_params)
              message = "Usuário foi salvo com sucesso com id: #{user[:id]}"
            else
              user = User.update_user(body_params)
              message = "Usuário com id: #{user[:id]} foi atualizado com sucesso."
            end
            {message: message, user: user}
          end

          def login_user(login_data)
            symbolize_keys!(login_data)

            user = DB[:users]
                       .select(:id, :name, :cpf, :email, :role_id, :created_at)
                       .where(email: login_data[:email], password: Digest::SHA1.hexdigest(login_data[:password]), deleted_at: nil).first

            user
          end

          def get_user_by_id_as_object(user_id)
            User.where(id: user_id).first
          end

          def get_user_by_id(user_id)
            user_data = DB[:users]
                            .select(Sequel.qualify(:users, :id), :cpf, :name, :email,
                                    Sequel.qualify(:users, :role_id), :created_at,
                                    Sequel.qualify(:roles, :description),
                                    Sequel.qualify(:roles, :code))
                            .join(:roles, id: Sequel.qualify(:users, :role_id))
                            .where(Sequel.qualify(:users, :id) => user_id).first

            if user_data
              user = {
                  id: user_data[:id],
                  cpf: user_data[:cpf],
                  name: user_data[:name],
                  email: user_data[:email],
                  created_at: user_data[:created_at],
                  role: {
                      id: user_data[:role_id],
                      description: user_data[:description],
                      code: user_data[:code]
                  }
              }
            else
              user = {}
            end

            {user: user}
          end

          # Pequisa por usuarios
          def find_user(body_params)
            query = '(query_name LIKE :query OR cpf LIKE :query OR email LIKE :query)'

            body_params[:query] = StringUtils.remove_accents(body_params[:query])
            body_params[:query].downcase!

            users = DB[:users]
                        .join(:roles, id: Sequel.qualify(:users, :role_id))
                        .extension(:pagination)
                        .select(Sequel.qualify(:users, :id),
                                Sequel.qualify(:users, :cpf),
                                Sequel.qualify(:users, :name),
                                Sequel.qualify(:users, :email),
                                Sequel.qualify(:users, :created_at),
                                Sequel.qualify(:roles, :id).as(:role_id),
                                Sequel.qualify(:roles, :description),
                                Sequel.qualify(:roles, :code))
                        .where(Sequel.lit(query, query: "%#{body_params[:query]}%"))
                        .where(Sequel.qualify(:users, :deleted_at) => nil)

            total_items = users.count

            users = users.paginate(body_params[:page].to_i, 20)

            user_array = []

            users.all.each do |user|
              user_data = {
                  id: user[:id],
                  cpf: user[:cpf],
                  name: user[:name],
                  email: user[:email],
                  created_at: user[:created_at],
                  role: {
                      id: user[:role_id],
                      description: user[:description],
                      code: user[:code]
                  }
              }

              user_array << user_data
            end

            {total_items: total_items, users: user_array}
          end

          def change_password(body_params, token, user)
            symbolize_keys!(body_params)

            is_valid = user.password.eql? Digest::SHA1.hexdigest(body_params[:password])

            raise ModelException, 'Impossível alterar a senha. Senha incorreta.' unless is_valid

            user = user.update(password: Digest::SHA1.hexdigest(body_params[:new_password]))

            invalidade_token(token)

            user
          end

          # Desabilitar usuario
          def disable_user(user_id)
            user = User.where(id: user_id).where(deleted_at: nil).first
            user.update(deleted_at: Time.now) if user

            msg = user.nil? ? "Usuário com o id: #{user_id} não encontrado" : "Usuário com id: #{user_id} excluído com sucesso"

            {msg: msg}
          end

          def list_disabled_users
            users = User.exclude(deleted_at: nil).all.map(&:values)
            {users: users}
          end

          def list_users_with_pagination(body_params)
            page = body_params[:pagina] || 1
            limit = body_params[:limite] || 20
            users = DB[:users].join(:roles, id: Sequel.qualify(:users, :role_id))
                        .select(Sequel.qualify(:users, :id),
                                Sequel.qualify(:users, :cpf),
                                Sequel.qualify(:users, :name),
                                Sequel.qualify(:users, :email),
                                Sequel.qualify(:users, :created_at),
                                Sequel.qualify(:roles, :id).as(:role_id),
                                Sequel.qualify(:roles, :description),
                                Sequel.qualify(:roles, :code))
                        .extension(:pagination).where(deleted_at: nil).order(:name)
            total_items = users.count
            users = users.paginate(page.to_i, limit).all

            user_array = []

            users.each do |u|
              user_array << {id: u[:id], email: u[:email], cpf: u[:cpf], name: u[:name],
                             role: {id: u[:role_id], description: u[:description], code: u[:code]}}
            end

            {total_items: total_items, users: user_array}
          end

          private

          def invalidade_token(token)
            user_token = DB[:user_tokens].where(token: token)
            user_token.delete if user_token
          end
        end
      end
    end
  end
end
