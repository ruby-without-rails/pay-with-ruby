require 'logger'
require 'yaml'
require 'json'
require 'sequel'
require 'codecode/common/utils'
require 'utils/discover_os'

module PayWithRuby
  module Models
    module Base
      # Database constants belong to this module namespace:

      private

      class << self
        def load_config_file
          file = 'database.conf.yml'
          file_path = File.dirname(__FILE__) + "/../../config/#{file}"
          YAML::load(File.open(file_path)) rescue fail "[Startup Info] - Arquivo de configuração [#{file}] não encontrado no diretório [#{file_path}]"
        end

        def load_db
          yaml = load_config_file
          default_config = yaml['default']
          prod_config = yaml['prod']
          develop_config = yaml['develop']
          homolog_config = yaml['homolog']

          case ENV['RACK_ENV']
            when 'PROD' then
              Sequel.postgres(prod_config)
            when 'HMG' then
              Sequel.postgres(homolog_config)
            when 'DEV' then
              Sequel.postgres(develop_config)
            else
              Sequel.postgres(default_config)
          end
        end
      end

      # Database access constants:
      DB = load_db

      #append log
      DB.loggers << Logger.new($stdout)

      unless PayWithRuby::Utils::DiscoverOS.os?.eql?(:windows)
        if Sequel::Postgres.supports_streaming?
          # If streaming is supported, you can load the streaming support into the database:
          DB.extension(:pg_streaming)
          # If you want to enable streaming for all of a database's datasets, you can do the following:
          DB.stream_all_queries = true
          puts '[Startup Info] - Postgresql streaming foi ativado.'
        end
      end

      # @class [ModelException]
      class ModelException < StandardError
        attr_reader :status, :message, :data, :code

        def initialize(message, status = 400, code = 0, data = {})
          @status = status
          @message = message
          @data = data
          @code = code
        end

        ##
        # Convert Exception contents to a Json string. All attributes must
        # be Json serializable.
        def to_json
          JSON.generate(to_hash)
        end

        def to_hash
          {status: @status, message: @message, code: @code, data: @data}
        end

        def to_response
          [@status, to_json]
        end
      end

      # Class [UnexpectedParamException]
      class UnexpectedParamException < ModelException; end

      # Class [AccessDeniedException]
      class AccessDeniedException < ModelException
        attr_reader :required_level

        # @param [String] message
        # @param [Integer] status
        # @param [String] required_level
        # @param [String] current_level
        # @return [AccessDeniedException]
        def initialize(message, status = 401, required_level, current_level)
          @status = status
          @message = message
          @required_level = required_level
          @current_level = current_level
        end

        def to_hash
          {status: @status, message: @message, required_level: @required_level, current_level: @current_level}
        end
      end

      # BaseModel is just an alias to Sequel::Model class:
      class BaseModel < Sequel::Model
        DEFAULT_CHARSET = 'UTF-8'.freeze

        @forced_encoding = DEFAULT_CHARSET
        set_dataset DB['']

        Sequel::Model.plugin :force_encoding, DEFAULT_CHARSET
        Sequel::Model.plugin :after_initialize
        Sequel::Model.require_valid_table = false
        Sequel.convert_two_digit_years = true

        Sequel.split_symbols = false

        extend CodeCode::Common::Utils::Hash
      end

      # Class [BusinessModel] is just a signal that a business class is generic
      # and it's not binded to a specific entity or connection in database.
      class BusinessModel
        def initialize
          raise 'Essa classe não pode ser instanciada.'
        end
      end

      # @class [IntegrationModel]
      class IntegrationModel < BusinessModel;
      end
    end
  end
end
