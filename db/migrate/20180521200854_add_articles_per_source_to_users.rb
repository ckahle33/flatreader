class AddArticlesPerSourceToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :articles_per_source, :integer
  end
end
