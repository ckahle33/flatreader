require 'rest-client'

class NewsApi
  def initialize
    @key = ENV['NEWS_API_KEY']
    @sources_url = ENV['NEWS_API_SOURCES_URL']
    @articles_url = ENV['NEWS_API_ARTICLES_URL']
  end

  def sources
    sources = RestClient.get @sources_url
    JSON.parse(sources)
  end

  def articles(source)
    articles = RestClient.get "#{@articles_url}?source=#{source}&sortBy=top&apiKey=#{@key}"
    JSON.parse(articles)
  end
end
