require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "sinatra/content_for"
require 'logger'
require "sinatra/flash"
require "better_errors"
require 'feedjira'
require "pry"

require 'dotenv'
Dotenv.load

require "./models/source"
require "./models/article"
require "./models/user"
require './lib/workers/text'

set :root, File.dirname(__FILE__)
set :environment, ENV['RACK_ENV']
set :views, "views"
set :database, {adapter: "postgresql", database: "flatreader_#{ENV['RACK_ENV']}"}

enable :sessions
set :sessions, :expire_after => 2419200

configure :development do
  logger = Logger.new(File.open("./log/#{ENV['RACK_ENV']}.log"), "a+")
  set :logger, logger
  enable :reloader
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__

  set :haml, format: :html5
end

before do
  env["rack.errors"] = logger
  @sources = Source.all
end

get '/' do
  @articles = Article.all.where.not(published_at: nil).order('published_at DESC').limit(100)
  haml :index, layout: :main
end

get '/all' do
  @articles = Article.all.where.not(published_at: nil).order('published_at DESC').limit(100)
  haml :index, layout: :main
end

get '/sources/:source_id' do
  @source   = Source.find(params['source_id'].to_i)
  @articles = Article.where(source_id: params['source_id']).order(published_at: :desc).limit(30)

  haml :source, layout: :main
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
  id = params[:id] if params[:id]
  s = Source.find(id.to_i)
  s.refresh_feed
  flash['alert-success'] = "feed refreshed!"
  redirect back
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
