require 'rss'
require 'open-uri'

class Source < ActiveRecord::Base
  after_create :create_articles

  def try_name(feed)
    if feed.try(:channel).present?
      feed.channel.title
    else
      feed.try(:category).label
    end
  end

  def create_articles
    open(self.url, "User-Agent" => "ruby/#{RUBY_VERSION}") do |rss|
      feed = RSS::Parser.parse(rss)
      self.update_attributes(name: try_name(feed))
      feed.items.each do |article|
        Article.find_or_create_by!({
          source_id:    self.id,
          title:        article.try(:title).to_s,
          url:          article.try(:link).to_s,
          published_at: article.try(:date),
        }) if article.try(:date).present? or article.try(:updated).present?
      end
    end
  end

end
