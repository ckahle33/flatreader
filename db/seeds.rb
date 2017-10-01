def date(d)
  Date.parse(d) || Time.now
end

def body(url)
  TextApi.new.summarize(url)['sentences']
end

@sources = NewsApi.new.sources['sources']

@sources.each do |s|
  Source.create(name: s["name"], slug: s["id"])
end

Source.all.each do |s|
  articles = NewsApi.new.articles(s['slug'])['articles']
  articles.each do |a|
    Article.find_or_create_by(source_id: s.id, published_at: date(a['publishedAt']) , author: a['author'] || "anon", url: a['url'], body: TextApi.new.summarize(a['url'])[:sentences])
  end
end

