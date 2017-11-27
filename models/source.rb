require 'rss'
require 'open-uri'

class Source < ActiveRecord::Base
  after_create :create_articles

  def create_articles
    open(self.url, "User-Agent" => "ruby/#{RUBY_VERSION}") do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |article|
        Article.find_or_create_by!({
          source_id: self.id,
          title: article&.title,
          url: article&.link,
          published_at: article&.date,
        }) if article&.date&.present? or article.try(:updated).present?
      end
    end
  end

end
