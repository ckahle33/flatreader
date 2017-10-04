require 'sidekiq'

class ArticleWorker
  include Sidekiq::Worker

  def perform
    # queue article creation eventually
  end
end
