require 'sidekiq'
require "sinatra/activerecord"
require 'feedjira'
require './models/source'

class RefreshWorker
  include Sidekiq::Worker

  def perform(id)
    s = Source.find(id)
    s.refresh_feed
  end
end
