require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/activerecord"
require "better_errors"
require 'dotenv/load'
require "pry"

require "./models/source"
require "./models/article"

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

get '/:url/*' do
  @sources = NewsApi.new.sources['sources']
  uri = "#{params[:url]}//#{params['splat'][0]}"

  @article = TextApi.new.summarize(uri)

  haml :article, layout: :main
end

helpers do
  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end
