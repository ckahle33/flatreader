class AddTimestampsToArticles < ActiveRecord::Migration[5.1]
  def change
    add_column :articles, :created_at, :timestamp, null: false
    add_column :articles, :updated_at, :timestamp, null: false
   end
end
