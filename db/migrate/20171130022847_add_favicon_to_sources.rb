class AddFaviconToSources < ActiveRecord::Migration[5.1]
  def change
    rename_column :sources, :slug, :favicon
  end
end
