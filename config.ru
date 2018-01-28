require_relative 'config/loadpath'
require_relative 'bin/apps'
require_relative 'lib/requires'

Rack::Handler.default.run(Rack::URLMap.new(
    '/mundipagg' => PayWithRuby::MundiPaggApis,
    '/vindi' => PayWithRuby::VindiApis,
    '/' => PayWithRuby::BaseApis,
    '/payments' => PayWithRuby::PaymentApis), :Port => 9292, :Host => '0.0.0.0')
