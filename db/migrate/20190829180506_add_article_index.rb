class AddArticleIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :articles, :source_id
    add_index :articles, :published_at
  end
end
