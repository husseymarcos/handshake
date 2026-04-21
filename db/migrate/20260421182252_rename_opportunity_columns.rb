class RenameOpportunityColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :opportunities, :company_name, :organization_name
    rename_column :opportunities, :job_description, :posting
  end
end
