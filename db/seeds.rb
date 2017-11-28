require "./source_list"
require 'uri'

SOURCE_LIST.each do |url|
  source = Source.find_or_create_by!(url: url)
  source.save!
  source.refresh_feed
end

