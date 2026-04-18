class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.text :blueprint_typst
      t.datetime :blueprint_updated_at, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
