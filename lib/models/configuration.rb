require 'requires'

include PayWithRuby::Models::Base

module PayWithRuby
  module Models
    module ConfigurationModule

      # @class [Configuration]
      class Configuration < BaseModel

        # Set Configuracao dataset:
        set_dataset DB[:configurations]

        # Set primary key and relationships:
        set_primary_key :name

        def validate
          super
        end

        class << self
          def save_configuration(name, value)
            c = Configuration.new
            c.name = name
            c.value = value if valid?
            c.save
          end

          def current_version
            conf = Configuration.where(name: 'version').first
            conf.values
          end

          def get_configuration(name)
            conf = Configuration.where(name: name).first
            fail "****************Configuracao [#{name}] não encontrada na tabela de configurações.****************" unless conf
            conf.values
          end

          def lista_configurations
            Configuration.all.map(&:values)
          end

          def list_apis(controller)
            routes = controller.routes
            post_routes = routes['POST'].collect {|r| r.first.to_s}
            get_routes = routes['GET'].collect {|r| r.first.to_s}
            delete_routes = routes['DELETE'].collect {|r| r.first.to_s}

            {post: post_routes, get: get_routes, delete: delete_routes}
          end
        end
      end
    end
  end
end

