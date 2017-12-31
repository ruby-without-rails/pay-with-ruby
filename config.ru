require_relative 'config/loadpath'
require_relative 'bin/apps'
require_relative 'lib/requires'

run Rack::URLMap.new('/mundipagg' => PayWithRuby::MundiPaggApis,
                     '/vindi' => PayWithRuby::VindiApis,
                     '/' => PayWithRuby::BaseApis,
                     '/payments' => PayWithRuby::PaymentApis)
