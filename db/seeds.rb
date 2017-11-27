require 'uri'
require 'rss'

def date(d)
  Date.parse(d) || Time.now
end

class ArticleBuilder
  def self.create_articles(source, name)
    feed = RSS::Parser.parse(source.url)
    feed.items.each do |article|
      Article.create!({
        source_id: source.id,
        title: article.title,
        url: article.link,
        published_at: article.date,
        source_name: name,
        body: article.description
      }) if article.date.present?
    end
  end
end

SOURCE_LIST.each do |url|
  source = Source.find_or_create_by!(url: url)
  feed = RSS::Parser.parse(url)
  name = URI.parse(feed.channel.link).host
  source.update_attributes({
    name: name,
    slug: name
  })
  source.save!
  ArticleBuilder.create_articles(source, name)
end
