require 'open-uri'

class Source < ActiveRecord::Base
  after_create :refresh_feed

  def refresh_feed
    feed = Feedjira::Feed.fetch_and_parse(self.url)
    self.update_attributes(name: feed.title)
    feed.entries.each do |article|
      a = Article.find_or_create_by!({
        source_id:    self.id,
        title:        article.try(:title).to_s,
      })
      a.update_attributes({
        url:          article.try(:url).to_s || article.try(:links).to_s,
        body:         article.try(:content).to_s,
        published_at: article.try(:date) || article.try(:last_modified) || article.try(:updated)
      })
    end
  end
  # end

end
