require "./source_list"
require 'uri'

SOURCE_LIST.each do |url|
  source = Source.find_or_create_by!(url: url)
  name = URI.parse(url).host
  source.save!
end

