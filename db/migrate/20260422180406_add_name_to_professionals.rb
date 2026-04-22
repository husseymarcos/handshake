class AddNameToProfessionals < ActiveRecord::Migration[8.1]
  def change
    add_column :professionals, :name, :string
  end
end
