require 'bundler/setup'
require 'sidekiq'
require 'sidekiq/web'
require 'dotenv'
Dotenv.load

require './app'

run Sinatra::Application

Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

# run Rack::URLMap.new('/sidekiq' => Sidekiq::Web)
