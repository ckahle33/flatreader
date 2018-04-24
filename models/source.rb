require 'open-uri'

class Source < ActiveRecord::Base
  after_create :refresh_feed
  has_many :articles
  has_many :users, through: :user_sources

  def favicon
    u = URI.parse(self.url)
    "https://www.google.com/s2/favicons?domain=#{u.host.sub(/^rss./, '')}"
  end

  def refresh_feed
    feed = Feedjira::Feed.fetch_and_parse(self.url)
    self.update_attributes(name: feed.title, favicon:favicon)
    feed.entries.each do |article|
      a = Article.find_or_initialize_by({
        source_id:    self.id,
        title:        article.try(:title)
      })
      a.update_attributes({
        url:          article.try(:url) || article.try(:links),
        body:         article.try(:content) || article.try(:summary),
        published_at: article.try(:date) || article.try(:last_modified) || article.try(:updated)
      })
    rescue
      next
    end
  end


end
