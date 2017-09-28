require "sinatra"
require "sinatra/reloader" if development?
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
  @links = []
  haml :index, layout: :main
end

get '/:site' do
  @links = []
  URL = "http://#{params[:site]}"
  doc ||= Nokogiri::HTML(open(URL))

  # binding.pry
  doc.css("#{link_selector(params[:site])} a").each do |link|
    if link.attribute('href') && @links.count < 50
      @links << build_link(link)
    end
  end

  haml :site, layout: :main
end

get '/:story/*' do
  uri = "#{params[:story]}//#{params['splat'][0]}"
  story ||= Nokogiri::HTML(open(uri))

  @story = story.css('main p')

  haml :story, layout: :main
end

def link_selector(site)
  #should live in db
  case site
    when /nytimes/
      'main .story-heading'
    when /cnn/
      'main ul li'
    when /npr/
      '#contentWrap .story-wrap'
    when /fox/
      'main'
    when /drudge/
      'table'
    end
end

def build_link(link)
  if link.attribute('href').value =~ /http/
    {href: "#{base_url}/#{link.attribute('href').value}", title: link.content}
  else
    {href: "#{base_url}/#{URL}#{link.attribute('href').value}", title: link.content}
  end
end

helpers do
  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end

