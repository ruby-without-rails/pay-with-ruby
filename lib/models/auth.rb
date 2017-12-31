require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module AuthModule

      ##
      # Specific class used to authenticate and authorize API users:
      class ApiAuther < BusinessModel
        class << self
          ##
          # Verify if a given access token has access to the system. If so,
          # returns true, otherwise, returns false.
          def authorize(token)
            user_token = AccessToken.where(token: token).where(Sequel.lit('expiration_time > :current_time', current_time: Time.now)).first

            error_msg = 'UserToken Not Found. User not authorized.'
            raise ModelException.new(error_msg, 401) if user_token.nil?

            true
          end

          def unauthorize(token)
            user_token = AccessToken.where(token: token).first
            user_token.delete if user_token
            !user_token.nil?
          end

          def unauthorize_or_raise(token)
            return_data = unauthorize(token)
            if return_data
              {mensagem: 'Logout realizado com sucesso.'}
            else
              raise ModelException, 'Não foi possível realizar logout.'
            end
          end

          ##
          # From given token, locate the correspondent user and return her/his
          # data.
          def identify(token)
            user_token = AccessToken.where(token: token).where(Sequel.lit('expiration_time > :current_time', current_time: Time.now)).first

            error_msg = 'User Token não encontrado.'
            raise ModelException.new(error_msg, 404) if user_token.nil?

            user_token
          end

          def clean_old_tokens(user = {}, customer = {})
            AccessToken.where(user_id: user[:id]).all.each {|ut| ut.delete} unless user.empty?
            AccessToken.where(customer_id: customer[:id]).all.each {|ut| ut.delete} unless customer.empty?
          end
        end
      end
    end
  end
end
