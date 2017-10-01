class CreateSources < ActiveRecord::Migration[5.1]
  def change
    create_table :sources do |s|
      s.string :name
      s.string :slug
    end
  end
end
