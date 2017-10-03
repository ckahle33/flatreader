require 'sidekiq'

class TextWorker
  include Sidekiq::Worker

  def perform(id)
    a = Article.find(id)
    a.update!(body:  TextApi.new.summarize(a['url'])[:sentences])
  end
end
