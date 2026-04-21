class RenameWorksToExperiences < ActiveRecord::Migration[8.1]
  def change
    rename_table :works, :experiences
  end
end
