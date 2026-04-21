class RenameSkillsToCapabilities < ActiveRecord::Migration[8.1]
  def change
    rename_table :skills, :capabilities
  end
end
