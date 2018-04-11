require 'uri'

SOURCE_LIST = ["http://nautil.us/rss/all", "http://rss.slashdot.org/Slashdot/slashdotMain", "https://www.theguardian.com/us-news/rss", "https://www.reddit.com/r/all.rss", "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", "http://www.dailymail.co.uk/articles.rss", "http://www.rollingstone.com/music/rss", "https://pitchfork.com/rss/reviews/albums/", "https://pitchfork.com/rss/news", "https://www.austinchronicle.com/gyrobase/rss/daily-music.xml", "https://www.austinchronicle.com/gyrobase/rss/daily.xml", "https://www.theguardian.com/us/rss", "https://www.reddit.com/r/programming.rss", "https://news.ycombinator.com/rss", "https://www.reddit.com/r/Showerthoughts/.rss", "https://www.austinchronicle.com/gyrobase/rss/issue.xml", "http://rss.cnn.com/rss/cnn_topstories.rss", "https://www.npr.org/rss/rss.php?id=1001"]

SOURCE_LIST.each do |url|
  source = Source.find_or_create_by!(url: url)
  source.save!
  source.refresh_feed
end

