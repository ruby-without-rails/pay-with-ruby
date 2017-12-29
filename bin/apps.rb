require 'sinatra'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'sinatra/sequel'
require 'sinatra/config_file'
require 'sinatra/namespace'

#
# Require Authentication Models:
#
require 'models/base'
require 'requires'

module PayWithRuby
  module Controllers
    # The Generic Base Controller
    module Base
      module ApiAuthFilter
        PUBLIC_PATHS = [
            /\/api\/login/
        ].freeze
      end

      # The Generic Authentication Filter class:
      module AuthFilter
        class << self
          def extended(filter)
            def filter.extended(controller)
              # Set the Base Controller auth filter:
              controller.set_auth_filter self
              auth_filter = self

              # Block all paths, by default:
              controller.before {

                authorize = true
                authorize = false if request.request_method == 'OPTIONS'

                auth_filter::PUBLIC_PATHS.each {|path| authorize = false if path.match(request.path_info)}

                #
                # Evaluate authorization code
                #
                if authorize

                  # 1. Get the PayWithRuby auth token:
                  auth_token = request.env['HTTP_PAYWITHRUBY_AUTH_TOKEN']

                  # 2. Authorize:
                  begin
                    ApiAuther.authorize(auth_token)
                  rescue
                    content_type 'application/json;charset=utf-8'

                    msg = 'PayWithRuby-Auth-Token inválido. Acesso não autorizado.'

                    response = {message: msg}

                    halt 401, JSON.generate(response)
                  end
                end
              }
            end
          end
        end
      end

      # Sentry Logger Filter class:
      module LoggerFilter
        class << self
          def extended(controller)
            controller.before {
              # Read and save request data to be used in the error handler
              @request_payload = request.body.read
              @request_payload = @request_payload.gsub("\n", "")
              @request_url = request.env['REQUEST_URI']
              @request_token = request.env['HTTP_PAYWITHRUBY_AUTH_TOKEN']
              request.body.rewind

              case request.env['REQUEST_METHOD']
                when 'POST', 'PUT' then
                  if @request_payload.nil? || @request_payload.empty?
                    exception = UnexpectedParamException.new 'Request sem parâmetros.'
                    content_type 'application/json;charset=utf-8'
                    halt 400, exception.to_json
                  end
              end
            }

            controller.error do
              # Log uncaught errors with Sentry, sending env variables
              # and the request body
              extra = env
              extra['REQUEST_BODY'] = @request_payload
              PayWithRuby::Utils::Logger.error(
                  env['sinatra.error'],
                  extra: extra
              )
            end
          end
        end
      end

      class BaseApp < Sinatra::Application
        # Extend especific filters:
        extend ApiAuthFilter
        extend LoggerFilter

        include Sinatra
        register SequelExtension, ConfigFile, CrossOrigin, Namespace

        config_filename = File.join(File.dirname(__FILE__), '../config/server.conf.yml')
        config_file config_filename

        # Set local configurations to Sinatra Application:
        # :development, :production, :test
        # Sinatra::Base.production? or Sinatra::Base.development? or Sinatra::Base.test?
        set environment: :development

        # Defaul Timezone
        ENV['TZ'] = settings.time_zone
        puts "[Startup Info] - TimeZone: #{ENV['TZ']}"

        set :server_settings, timeout: settings.timeout
        puts "[Startup Info] - Default Timeout: #{settings.timeout} s"
        set :bind, settings.bind_ip
        puts "[Startup Info] - Executando no ip: #{settings.bind_ip}"
        set :port, settings.bind_port
        puts "[Startup Info] - Executando na porta: #{settings.bind_port}"

        set :server, %w[thin webrick]
        set :show_exceptions, settings.show_exceptions
        set :raise_errors, settings.raise_errors
        set :protection, except: %i[json_csrf frame_options]
        set :cross_origin, settings.cross_origin

        # https://github.com/britg/sinatra-cross_origin#responding-to-options
        if settings.cross_origin
          options '*' do
            response.headers['Access-Control-Allow-Methods'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
            response.headers['Access-Control-Allow-Headers'] = 'PayWithRuby-Auth-Token, X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorize'
            200
          end
        end

        # public folder config
        # set :root, File.dirname(__FILE__)
        set :public_folder, File.expand_path('.', File.join(File.dirname(__FILE__), '../public'))
      end
    end


  end

  class MundiPaggApis < PayWithRuby::Controllers::Base::BaseApp
    require 'routes/mundi_pagg_routes'
    extend MundiPaggRoutes
  end

  class VindiApis < PayWithRuby::Controllers::Base::BaseApp
    require 'routes/vindi_routes'
    extend VindiRoutes
  end

  class BaseApis < PayWithRuby::Controllers::Base::BaseApp
    require 'routes/user_routes'
    extend UserRoutes
  end
end
