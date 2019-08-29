class AddArticleIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :articles, [:source_id, :published_at]
  end
end
