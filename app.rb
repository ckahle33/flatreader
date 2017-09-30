require "sinatra"
require "sinatra/reloader" if development?
require "better_errors"
require "nokogiri"
require "net/http"
require 'dotenv/load'
require "open-uri"
require "pry"

require './api/news'
require './api/text'

set :root, File.dirname(__FILE__)

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :views, "views"

get '/' do
  @sources = NewsApi.new.sources['sources']

  haml :index, layout: :main
end

get '/:site' do
  @sources = NewsApi.new.sources['sources']
  @title = @sources.select{|h| h['id'] == params['site']}[0]['name'].downcase
  @headlines = NewsApi.new.articles(params[:site])['articles']

  haml :site, layout: :main
end
