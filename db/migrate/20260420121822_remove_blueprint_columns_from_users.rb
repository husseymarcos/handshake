class RemoveBlueprintColumnsFromUsers < ActiveRecord::Migration[8.1]
  def up
    remove_column :users, :blueprint_typst, :text
    remove_column :users, :blueprint_updated_at, :datetime
  end

  def down
    add_column :users, :blueprint_typst, :text
    add_column :users, :blueprint_updated_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" }
  end
end
