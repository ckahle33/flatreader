require 'aylien_text_api'

class TextApi
  # queue these in cron
  def initialize
    @textapi = AylienTextApi::Client.new(app_id: ENV['TEXT_API_ID'], app_key: ENV["TEXT_API_KEY"])
  end

  def summarize(url)
    @textapi.summarize(url: url, sentences: 5)
  end
end
