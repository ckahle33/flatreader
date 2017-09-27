require "sinatra"
require "better_errors"
require "nokogiri"
require "net/http"
require "open-uri"
require "pry"

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

set :views, "views"

get '/' do
  @hello = 'Hello!'

  haml :index
end

get '/:site' do
  @cnn = []
  URL = "http://#{params[:site]}"
  doc ||= Nokogiri::HTML(open(URL))

  # binding.pry
  doc.css('.cd__headline', 'a').each do |link|
    @cnn << link.content
  end

  @nyt = []
  doc.css('.story-heading', 'a').each do |link|
    @nyt << link.content if @nyt.count < 30
  end

  haml :site
end


