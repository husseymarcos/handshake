class RenameJobDescriptionTruncatedColumn < ActiveRecord::Migration[8.1]
  def change
    rename_column :opportunities, :job_description_truncated, :posting_truncated
  end
end
