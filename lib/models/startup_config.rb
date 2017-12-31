require 'singleton'

module PayWithRuby
  module Models
    module ConfigurationModule

      # @class [StartupConfig]
      class StartupConfig
        include Singleton

        attr_reader :environment

        # Obtem configurações e parametros de ambiente da tabela de configuração
        def initialize
          @environment = discover_environment

          case @environment
            when :develop then
              @merchant_key_mundipagg = get_configuration('api_key_mundipagg_sand')
              @base_url_mundipagg = get_configuration('mundipagg_sand_base_url')
            when :prod then
              @merchant_key_mundipagg = get_configuration('api_key_mundipagg_prod')
              @base_url_mundipagg = get_configuration('mundipagg_prod_base_url')
            else
              fail '[Startup Info] - Não foi possível descobrir o ambiente. [PROD], [DEV] ou [TEST] ?'
          end

          create_setters(%w[version])

          create_getters

          puts "[Startup Info] - Executando com ambiente de #{ENV['RACK_ENV']}" if ENV['RACK_ENV']
        end

        def get_configuration(nome)
          conf = PayWithRuby::Models::ConfigurationModule::Configuration.get_configuration(nome)
          conf[:value].freeze
        end

        private

        def discover_environment
          case ENV['RACK_ENV']
            when 'DEV', 'TEST' then
              :develop
            when 'PROD' then
              :prod
            else
              :undefined
          end
        end

        def create_setters(names)
          names.each {|n| instance_variable_set("@#{n}", get_configuration(n))}
        end

        def create_getters
          instance_variables.each {|v| define_singleton_method(v.to_s.tr('@', '')) {instance_variable_get(v)}}
        end
      end
    end
  end
end

