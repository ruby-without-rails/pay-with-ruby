require_relative 'lib/utils/discover_os'

source 'https://rubygems.org'
ruby '2.4.5'
# gem install bundler -v 1.10.6
gem 'bundler', '1.10.6'
gem 'codecode-common-utils'
gem 'rest-client','1.8'

gem 'i18n'
gem 'mustache'
gem 'rubocop'
gem 'mundipagg_sdk', '1.4.1'

gem 'sentry-raven'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-cross_origin'
gem 'sinatra-sequel'

gem 'pg'

gem 'sequel', '< 5'
# A gem 'sequel_pg' não funciona em ambiente Windows.
gem 'sequel_pg', require: 'sequel' unless PayWithRuby::Utils::DiscoverOS.os?.eql?(:windows)

gem 'thin'
