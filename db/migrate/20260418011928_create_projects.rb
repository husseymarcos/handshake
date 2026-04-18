class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :year
      t.string :title
      t.text :description
      t.string :stack
      t.string :github_url

      t.timestamps
    end
  end
end
