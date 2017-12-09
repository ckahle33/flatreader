require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/activerecord"
require "sinatra/content_for"
require "sinatra/flash"
require "better_errors"
require 'feedjira'
require "pry"

require './api/news'
require "./models/source"
require "./models/article"
require "./models/user"
require './lib/workers/text'
require 'dotenv'
Dotenv.load

set :root, File.dirname(__FILE__)

set :environment, ENV['RACK_ENV']

enable :sessions

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

get '/sources/:source_id' do
  @source   = Source.find(params['source_id'].to_i)
  @articles = Article.where(source_id: params['source_id']).order(published_at: :desc).limit(30)

  haml :source, layout: :main
end

get '/sources/:source_id/articles/:id' do
  @article = Article.find(params['id'])
  haml :article, layout: :main
end

post '/create' do
  url = URI.parse(params[:url])
  begin
    if Source.find_or_create_by!(url: url.to_s)
      flash['alert-success'] = "saved!"
      redirect "/"
    end
  rescue
      flash['alert-danger'] = "couldn't save dude"
      redirect "/"
  end
end

get '/refresh/:id' do
  id = params[:id ]if params[:id]
  s = Source.find(id.to_i)
  s.refresh_feed
  flash['alert-success'] = "feed refreshed!"
  redirect "/sources/#{id}"
end

# move these to separate file

get '/signup' do
  haml :signup, layout: :main
end

post '/users' do
  user = User.new(email: params[:email], password: params[:password], password_confirmation: params[:params_confirmation])

  if user.save!
    session[:user_id] = user.id
    redirect '/'
  else
    flash['alert-danger'] = "there was some dumb error trying to create your account"
    redirect '/'
  end
end

get '/login' do
  haml :login, layout: :main
end

post '/login' do
  user = User.find_by_email(params[:email])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    flash['alert-success'] = 'logged in'
    redirect '/'
  else
    flash['alert-danger'] = "your credentials are wrong"
    redirect '/login'
  end
end

get '/logout' do
  session[:user_id] = nil
  redirect '/'
end

get '/settings' do
  haml :settings, layout: :main
end

helpers do
  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
