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
require "./models/user_source"
require './lib/workers/text'

set :root, File.dirname(__FILE__)
set :environment, ENV['RACK_ENV']
set :views, "views"
set :database, {adapter: "postgresql", database: "flatreader_#{ENV['RACK_ENV']}"}


configure :development, :production do
  # sessions
  set :sessions, :expire_after => 2592000, key: 'flatreader.session'
  set :session_secret, ENV['SESSION_SECRET']

  #logging
  enable :logging, :dump_errors, :raise_errors
  logger = Logger.new(File.open("./log/#{ENV['RACK_ENV']}.log"), "a+")
  set :logger, logger

  #reloading
  enable :reloader

  # errors
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__

  set :haml, format: :html5
end

configure :production do
  # sessions
  set :sessions, :expire_after => 2592000, key: 'flatreader.session'
  set :session_secret, ENV['SESSION_SECRET']

  #logging
  enable :logging, :dump_errors
  logger = Logger.new(File.open("./log/#{ENV['RACK_ENV']}.log"), "a+")
  set :logger, logger

  set :haml, format: :html5
end

before do
  @current_user ||= User.find(session['user_id']) if session['user_id']
  env["rack.errors"] = logger
  @user_sources ||= UserSource.where(user_id: @current_user["id"]) if @current_user
  # raise 'hi'
end

get '/' do
  if @current_user
    @articles = Article.where(source_id: user_source_ids).where.not(published_at: nil).order('published_at DESC').limit(100) # will paginate here
    haml :index, layout: :main
  else
    haml :splash, layout: :main
  end
end

get '/all' do
  authenticate!
  @sources = Source.all
  # @articles = Article.all.where.not(published_at: nil).order('published_at DESC').limit(100)
  haml :all, layout: :main
end

get '/sources/:source_id' do
  authenticate!
  @source   = Source.find(params['source_id'].to_i)
  @articles = Article.where(source_id: params['source_id']).order(published_at: :desc).limit(30)

  haml :source, layout: :main
end

get '/add/:source_id' do
  authenticate!
  @source   = Source.find(params['source_id'].to_i)
  if UserSource.find_or_create_by!(source_id: @source.id, user_id: current_user['id'])
    flash['alert-success'] = "added source!"
    redirect back
  else
    flash['alert-error'] = "couldn't add source..."
    redirect back
  end

end

get '/remove/:user_source_id' do
  authenticate!
  if UserSource.destroy(params["user_source_id"])
    flash['alert-success'] = "removed source!"
    redirect back
  else
    flash['alert-error'] = "couldn't remove source..."
    redirect back
  end

end

post '/create' do
  authenticate!
  url = URI.parse(params[:url])
  begin
    if Source.find_or_create_by!(url: url.to_s)
      flash['alert-success'] = "saved!"
      redirect back
    end
  rescue
      flash['alert-danger'] = "couldn't save dude"
      redirect back
  end
end

post '/search' do
  authenticate!
  query = params["q"]

  @sources = Source.where("name ILIKE ?", "%#{query}%")
  haml :all, layout: :main
  # redirect "/search?q=#{query}"
end

get '/search' do
  authenticate!
  query = params["q"]
  @sources = Source.where("name ILIKE ?", "%#{query}%")
  haml :all, layout: :main
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
    @current_user = user
    flash['alert-success'] = 'logged in'
    redirect '/'
  else
    flash['alert-danger'] = "email or password was incorrect"
    redirect '/login'
  end
end

get '/logout' do
  session.clear
  redirect '/login'
end

get '/settings' do
  # dark mode toggle handling here
  haml :settings, layout: :main
end

helpers do
  def authenticate!
    if session['user_id']
      @current_user ||= User.find(session['user_id'])
    else
      redirect to '/login'
    end
  end

  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_source_ids
    current_user.sources.map(&:id) if current_user
  end
end
