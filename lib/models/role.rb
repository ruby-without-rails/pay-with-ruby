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

          def delete_role(role_id)
            role = Role[role_id]
            role.delete if role

            msg = role.nil? ? "Perfil com o id: #{role_id} não encontrado" : "Perfil com id: #{role_id} excluído com sucesso"

            {msg: msg}
          end

          def list_roles
            roles = Role.all.map(&:values)
            {roles: roles}
          end

          def get_role_by_id(role_id)
            role = Role.where(id: role_id).first
            {role: role.nil? ? {} : role.values}
          end

          def get_role_by_code(code)
            role = Role.where(code: code).first
            {role: role.nil? ? {} : role.values}
          end

          def get_role_by_name(descricao)
            role = Role.where(description: descricao).first
            {role: role.nil? ? {} : role.values}
          end
        end
      end
    end
  end
end
