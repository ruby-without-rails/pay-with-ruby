require_relative 'lib/utils/discover_os'

source 'https://rubygems.org'
ruby '>= 1.9.3'


gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-cross_origin'
gem 'sinatra-sequel'

gem 'pg'

gem 'sequel' , '< 5'
# A gem 'sequel_pg' não funciona em ambiente Windows.
gem 'sequel_pg', require: 'sequel' unless PayWithRuby::Utils::DiscoverOSUtil.os?.eql?(:windows)
gem 'sequel-postgres-schemata'

gem 'thin'