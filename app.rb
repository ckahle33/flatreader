require "rubygems"
require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "sinatra/content_for"
require "sinatra/flash"
require "pg"
require 'logger'
require "better_errors"
require 'feedjira'
require "pry"
require 'omniauth'
require 'omniauth-twitter'
require 'sidekiq'
require 'sidekiq-cron'

require 'dotenv'
require 'bundler'

Dotenv.load
Bundler.require(:default)

require "./models/source"
require "./models/article"
require "./models/user"
require "./models/tag"
require "./models/source_tag"
require "./models/user_source"
require './workers/refresh_worker'
require './workers/refresh_all_worker'
require 'tilt'

class App < Sinatra::Base

  Tilt.register Tilt::ERBTemplate, 'html.erb'

  set :root, File.dirname(__FILE__)
  set :environment, ENV['RACK_ENV']
  set :views, "views"
  register Sinatra::Flash

  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_API_KEY'], ENV['TWITTER_API_SECRET']
  end

  def self.base_config
  ActiveRecord::Base.establish_connection(
     :adapter  => 'postgresql',
     :host     => 'localhost',
     :database => "flatreader_#{ENV['RACK_ENV']}",
     :encoding => 'utf8',
     :pool => 30
   )
    # sessions
    set :sessions, :expire_after => 2592000, key: 'flatreader.session'
    set :session_secret, ENV['SESSION_SECRET']

    #logging
    file = File.new("./log/#{ENV['RACK_ENV']}.log", "a+")
    file.sync = true
    use Rack::CommonLogger, file

    set :erb, {escape_html: true}
  end

  configure :development do
    register Sinatra::Reloader
    set :reload_templates, true

    base_config
    enable :logging, :dump_errors, :raise_errors

    # errors
    use BetterErrors::Middleware
    BetterErrors.application_root = __dir__
  end

  configure :production do
    base_config
    enable :logging, :dump_errors
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
      erb :index, layout: :main
    else
      erb :splash, layout: :main
    end
  end

  get '/all' do
    authenticate!
    @sources = Source.all
    # @articles = Article.all.where.not(published_at: nil).order('published_at DESC').limit(100)
    erb :all, layout: :main
  end

  get '/sources/:source_id' do
    authenticate!
    @source   = Source.find(params['source_id'].to_i)
    @articles = Article.where(source_id: params['source_id']).order(published_at: :desc).limit(30)

    erb :source, layout: :main
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
    tags = params[:tags]
    begin
      source = Source.find_or_create_by!(url: url.to_s)
      if source
        UserSource.find_or_create_by!(source_id: source.id, user_id: @current_user['id'])
        if tags
          tags.split(',').each do |t|
            t = Tag.find_or_create_by(name: t)
            SourceTag.create(tag_id: t.id, source_id: source.id)
          end
        end
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
    erb :all, layout: :main
    # redirect "/search?q=#{query}"
  end

  get '/refresh/:id' do
    id = params[:id] if params[:id]
    s = Source.find(id.to_i)
    s.refresh_feed
    flash['alert-success'] = "feed refreshed!"
    redirect back
  end

  get '/tags' do
    @tags = Tag.all
    erb :tags, layout: :main
  end

  get '/tag/:id' do
    @tag  = Tag.find(params[:id])
    erb :tag, layout: :main
  end

  # move these to separate file

  get '/signup' do
    erb :signup, layout: :main
  end

  post '/users' do
    user = User.new(email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation])

    if user.save!
      session[:user_id] = user.id
      @current_user = user
      redirect '/'
    else
      flash['alert-danger'] = "there was some dumb error trying to create your account"
      redirect '/'
    end
  end

  get '/login' do
    erb :login, layout: :main
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

  get '/auth/:name/callback' do
    user = User.find_by(email: auth_hash.info.name)
    if user
      session[:user_id] = user.id
      @current_user = user
      redirect '/'
    else
      user = User.new(email: auth_hash.info.name, password: auth_hash['credentials']['token'], password_confirmation: auth_hash['credentials']['token'])
      if user.save!
        session[:user_id] = user.id
        @current_user = user
        redirect '/'
      else
        flash['alert-danger'] = "there was an error trying to create your account"
        redirect '/'
      end
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  get '/settings' do
    # dark mode toggle handling here
    erb :settings, layout: :main
  end

  post '/settings' do
    authenticate!
    articles_per_source = params[:articles_per_source]
    if current_user.update(articles_per_source: articles_per_source)
      flash['alert-success'] = "Settings saved!"
      redirect back
    else
      flash['alert-error'] = "Error saving settings..."
      redirect back
    end
  end

  helpers do
    def auth_hash
      env['omniauth.auth']
    end

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

    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

end
