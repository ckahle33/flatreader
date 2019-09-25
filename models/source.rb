require 'open-uri'
require 'httparty'

class Source < ActiveRecord::Base
  after_create :refresh_feed
  has_many :articles
  has_many :users, through: :user_sources
  has_many :source_tags
  has_many :tags, through: :source_tags

  def favicon
    u = URI.parse(self.url)
    "https://www.google.com/s2/favicons?domain=#{u.host.sub(/^rss./, '')}"
  end

  def refresh_feed
    Feedjira.logger.level = ::Logger::FATAL
    if HTTParty.get(self.url).response.code == "429"
      next
    else
      xml = HTTParty.get(self.url).body
      feed = Feedjira.parse(xml)
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
      end
    end
  end


end
