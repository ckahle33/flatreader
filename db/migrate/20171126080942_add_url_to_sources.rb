class AddUrlToSources < ActiveRecord::Migration[5.1]
  def change
    add_column :sources, :url, :string
  end
end
