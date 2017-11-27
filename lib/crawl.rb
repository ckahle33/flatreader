class Crawl
  def link_selector(site)
    # this will be ugly, but if we dont have an rss feed, try to grab the headline links from homepage, may involve watir for headless js.
  end

  def build_link(link)
    if link.attribute('href').value =~ /http/
      {href: "#{base_url}/#{link.attribute('href').value}", title: link.content}
    else
      {href: "#{base_url}/#{@url}#{link.attribute('href').value}", title: link.content}
    end
  end
end
