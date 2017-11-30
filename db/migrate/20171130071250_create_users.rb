class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |s|
      s.string :email
      s.string :password_digest
    end
  end
end
