require_relative 'config/loadpath'
require_relative 'bin/apps'
require_relative 'requires'

run Rack::URLMap.new('/mundipagg' => PayWithRuby::MundiPaggApis, '/vindi' => PayWithRuby::VindiApis)
