class RenameProjectsToWorks < ActiveRecord::Migration[8.1]
  def change
    rename_table :projects, :works
  end
end
