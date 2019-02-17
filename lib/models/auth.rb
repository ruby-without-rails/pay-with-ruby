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
            access_token = AccessToken.where(key: token).where(Sequel.lit('expires_at > :current_time', current_time: Time.now)).first
            raise ModelException.new('Access Token Not Found. User not authorized.', 401) unless access_token

            true
          end

          def unauthorize(token)
            access_token = AccessToken.where(key: token).first
            access_token.delete if access_token
            !access_token.nil?
          end

          def unauthorize_or_raise(token)
            return_data = unauthorize(token)
            if return_data
              {message: 'Logout realizado com sucesso.'}
            else
              raise ModelException, 'Não foi possível realizar logout.'
            end
          end

          ##
          # From given token, locate the correspondent user and return her/his
          # data.
          def identify(token)
            access_token = AccessToken.where(key: token).where(Sequel.lit('expires_at > :current_time', current_time: Time.now)).first
            raise ModelException.new('Access Token não encontrado.', 404) unless access_token

            access_token
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
