require 'rss'

class Source < ActiveRecord::Base
  after_create :create_articles

  def create_articles
    feed = RSS::Parser.parse(self.url)
    binding.pry
    feed.items.each do |article|
      Article.create!({
        source_id: self.id,
        title: article.title,
        url: article.link,
        published_at: article.date,
        body: article.description
      }) if article.date.present?
    end
  end

end
