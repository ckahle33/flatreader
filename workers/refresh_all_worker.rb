require 'sidekiq'
require "sinatra/activerecord"
require './workers/refresh_worker'

class RefreshAllWorker
  include Sidekiq::Worker

  def perform
    Source.all.each {|s| RefreshWorker.perform_async(s.id)}
  end
end
