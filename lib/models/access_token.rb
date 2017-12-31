require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module AuthModule

      # @class [AccessToken]
      class AccessToken < BaseModel

        # Set AccessToken dataset:
        set_dataset DB[:access_tokens]

        # Set primary key and relationships:
        set_primary_key :id
        many_to_one(:user, class: 'PayWithRuby::Models::UserModule::User', key: :user_id)
        many_to_one(:customer, class: 'PayWithRuby::Models::CustomerModule::Customer', key: :customer_id)

        # def initialize; end

        class << self
          def save_access_token(user = {}, customer = {}, request_ip)
            user_token = AccessToken.new
            user_token.user_id = user[:id]
            user_token.customer_id = customer[:id]
            user_token.expires_at = Time.now + 36_000
            user_token.token = TokenUtils.generate(255)
            user_token.ip = request_ip

            user_token.save
            user_token
          end

          def get_access_token_by_token(token)
            AccessToken.where(token: token).where(Sequel.lit('expires_at > :current_time', current_time: Time.now)).first
          end

          def invalidade_token(token)
            user_token = AccessToken.where(token: token).first
            user_token.delete if user_token
          end
        end
      end
    end
  end
end
