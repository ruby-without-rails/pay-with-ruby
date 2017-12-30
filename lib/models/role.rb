require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module UserModule

      # @class [Role]
      class Role < BaseModel
        # Set Role dataset:
        set_dataset DB[:roles]

        # Set primary key and relationships:
        set_primary_key :id

        # def initialize; end

        class << self
          def save_role(role_data)
            role = Role.new
            role.description = role_data[:description]
            role.code = role_data[:code]

            role.save
            role
          end

          def list_roles
            roles = Role.all.map(&:values)
            {roles: roles}
          end

          def get_role_by_id(role_id)
            Role.where(id: role_id).first
          end

          def get_role_by_code(code)
            Role.where(code: code).first
          end

          def get_role_by_name(descricao)
            Role.where(description: descricao).first
          end
        end
      end
    end
  end
end
