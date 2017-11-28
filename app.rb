require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/activerecord"
require "sinatra/content_for"
require "sinatra/flash"
require "better_errors"
require 'dotenv/load'
require "pry"

require './api/news'
require "./models/source"
require "./models/article"
require './lib/workers/text'

set :root, File.dirname(__FILE__)

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :views, "views"

before do
  @sources = Source.all
end

get '/' do
  haml :index, layout: :main
end

get '/:source' do
  @source   = Source.find(params['source'].to_i)
  @articles = Article.where(source_id: params['source']).order(published_at: :desc).limit(30)

  haml :source, layout: :main
end

get '/:source/:id' do
  @article = Article.find(params['id'])

  haml :article, layout: :main
end

post '/create' do
  url = URI.parse(params[:url])
  begin
    if Source.find_or_create_by!(url: url.to_s)
      flash[:success] = "saved!"
      redirect "/"
    end
  rescue
      flash[:error] = "couldn't save dude"
      redirect "/"
  end

end

def get_feed(url)
  open(url, "User-Agent" => "ruby/#{RUBY_VERSION}") do |rss|
    feed = RSS::Parser.parse(rss)
  end
end

helpers do
  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end
