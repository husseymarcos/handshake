class RenameUserIdColumnsToProfessionalId < ActiveRecord::Migration[8.1]
  def change
    rename_column :sessions, :user_id, :professional_id
    rename_column :capabilities, :user_id, :professional_id
    rename_column :works, :user_id, :professional_id
    rename_column :opportunities, :user_id, :professional_id
  end
end
