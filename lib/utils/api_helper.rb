require 'sinatra'
require 'json'

require 'models/base'

module PayWithRuby
  module Utils
    module ApiHelper
      include PayWithRuby::Models::Base
      include Sequel
      include Sinatra

      def make_default_json_api(api_instance, payload = {})
        request_method = api_instance.env['REQUEST_METHOD']
        if payload.empty? && (request_method.eql?('GET') || request_method.eql?('DELETE'))
          begin
            api_instance.content_type 'application/json;charset=utf-8'
            status = 200
            block_given? ? response = yield : response = { msg: 'Api não implementada.' }
          rescue ModelException => e
            status = 400
            response = { errors: [{ msg: e.message }] }
          end
          [status, response.to_json.gsub("\n",'')]
        else
          begin
            api_instance.content_type 'application/json;charset=utf-8'
            body_params = !payload.empty? && !payload.is_a?(IndifferentHash) && payload.length >= 2 ? JSON.parse(payload) : payload
            HashUtils.symbolize_keys!(body_params)

            status = 200

            if block_given?
              return_data = yield(body_params, status)
              status = return_data[:status]
              response = return_data[:response]
            else
              response = { msg: 'Api não implementada.' }
            end
          rescue ModelException => e
            status = 400
            response = { errors: [{ msg: e.message }] }
          rescue ConstraintViolation, UniqueConstraintViolation, CheckConstraintViolation,
              NotNullConstraintViolation, ForeignKeyConstraintViolation => e
            message = e.message[/DETAIL:(.*)/]
            status = 400
            response = { errors: [{ msg: message }] }
          end
          [status, response.to_json.gsub("\n",'')]
        end
      end
    end

    module ApiValidation
      include PayWithRuby::Models::Base

      def validate_params(body_params, symbols)
        symbols.each{|s| raise ModelException.new "Parâmetro #{s.to_s} não encontrado. Payload incorreto." unless body_params.has_key?(s) }
      end
    end
  end
end
