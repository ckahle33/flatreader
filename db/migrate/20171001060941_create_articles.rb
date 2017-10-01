class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |a|
      a.integer  :source_id
      a.datetime :published_at
      a.string   :author
      a.string   :url
      a.string   :source_name
      a.text     :body
    end
  end
end
