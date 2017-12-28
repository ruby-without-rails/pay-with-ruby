require 'sinatra'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'sinatra/sequel'
require 'sinatra/config_file'
require 'sinatra/namespace'

module PayWithRuby
  class BaseApis < Sinatra::Application
    register Sinatra::SequelExtension, Sinatra::ConfigFile, Sinatra::CrossOrigin, Sinatra::Namespace

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

    if settings.cross_origin
      # https://github.com/britg/sinatra-cross_origin#responding-to-options
      options '*' do
        response.headers['Access-Control-Allow-Methods'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'PayWithRuby-Auth-Token, X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorize'
        200
      end
    end

    # public folder config
    # set :root, File.dirname(__FILE__)
    set :public_folder, File.expand_path('.', File.join(File.dirname(__FILE__), '../public'))

    # Application code
    run! if app_file == $0
  end

  class MundiPaggApis < BaseApis
    require 'controllers/mundi_pagg_routes'
    extend MundiPaggRoutes
  end

  class VindiApis < BaseApis; end
end
