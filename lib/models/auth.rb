require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module AuthModule

      # @class [UserToken]
      class UserToken < BaseModel

        # Set UserToken dataset:
        set_dataset DB[:user_tokens]

        # Set primary key and relationships:
        set_primary_key :id
        many_to_one(:user, class: 'PayWithRuby::Models::UserModule::User', key: :user_id)

        # def initialize; end

        class << self
          def save_user_token(user_id)
            user_token = UserToken.new
            user_token.user_id = user_id
            user_token.expiration_time = Time.now + 36_000
            user_token.token = TokenUtils.generate(255)

            user_token.save
            user_token
          end

          def get_user_by_token(token)
            UserToken.where(token: token).where(Sequel.lit('expiration_time > :current_time', current_time: Time.now)).first
          end

          def invalidade_token(token)
            user_token = UserToken.where(token: token).first
            user_token.delete if user_token
          end
        end
      end

      ##
      # Specific class used to authenticate and authorize API users:
      class ApiAuther < BusinessModel
        class << self
          ##
          # Verify if a given access token has access to the system. If so,
          # returns true, otherwise, returns false.
          def authorize(token)
            user_token = UserToken.where(token: token).where(Sequel.lit('expiration_time > :current_time', current_time: Time.now)).first

            error_msg = 'UserToken Not Found. User not authorized.'
            raise ModelException.new(error_msg, 401) if user_token.nil?

            true
          end

          def unauthorize(token)
            user_token = UserToken.where(token: token).first
            user_token.delete if user_token
            !user_token.nil?
          end

          def unauthorize_or_raise(token)
            return_data = unauthorize(token)
            if return_data
              { mensagem: 'Logout realizado com sucesso.' }
            else
              raise ModelException, 'Não foi possível realizar logout.'
            end
          end

          ##
          # From given token, locate the correspondent user and return her/his
          # data.
          def identify(token)
            user_token = UserToken.where(token: token).where(Sequel.lit('expiration_time > :current_time', current_time: Time.now)).first

            error_msg = 'User Token não encontrado.'
            raise ModelException.new(error_msg, 404) if user_token.nil?

            user_token
          end
        end
      end
    end
  end
end
