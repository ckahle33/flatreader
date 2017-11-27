require "./source_list"
require 'uri'

def date(d)
  Date.parse(d) || Time.now
end

SOURCE_LIST.each do |url|
  source = Source.find_or_create_by!(url: url)
  name = URI.parse(url).host
  source.update_attributes({
    name: name,
    slug: name
  })
  source.save!
end
