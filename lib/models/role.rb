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

        def validate
          super
          errors.add(:description, 'cannot be null') if description.nil?
          errors.add(:description, 'must be a String') if description and description.match?(/\d/)
          errors.add(:description, 'cannot be empty') if description and not description.match?(/\d/) and description.empty?
          errors.add(:description, 'must be have 6 characters') if description and not description.match?(/\d/) and description.size < 6

          errors.add(:code, 'cannot be null') if code.nil?
          errors.add(:code, 'must be a String') if code and code.match?(/\d/)
          errors.add(:code, 'cannot be empty') if code and not code.match?(/\d/) and code.empty?
          errors.add(:code, 'must be have 6 characters') if code and not code.match?(/\d/) and code.size < 4
        end

        class << self
          def save_role(role_data)
            id = role_data[:id]

            if not id.nil? and id.match?(/\d/)
              role = Role[id]
            else
              role = Role.new
            end

            role.description = role_data[:description]
            role.code = role_data[:code]

            if role.valid?
              role.save
              message = role.exists? ? 'Perfil foi atualizado com sucesso!': 'Perfil foi salvo com sucesso!'
              {role: role.values, message: message}
            else
              {validation_errors: role.errors}
            end
          end

          def delete_role(role_id)
            begin
              role = Role[role_id]
              role.delete if role
              msg = role.nil? ? "Perfil com o id: #{role_id} não encontrado" : "Perfil com id: #{role_id} excluído com sucesso"
            rescue Sequel::ForeignKeyConstraintViolation
              msg = 'Não é possível realizar a remoção do perfil.\n Descadastre os usuários ativos com este perfil e repita a operação.'
              raise ModelException.new msg
            end

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
