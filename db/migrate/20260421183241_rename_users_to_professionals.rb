class RenameUsersToProfessionals < ActiveRecord::Migration[8.1]
  def change
    rename_table :users, :professionals
  end
end
