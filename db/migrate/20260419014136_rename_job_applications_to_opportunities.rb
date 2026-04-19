class RenameJobApplicationsToOpportunities < ActiveRecord::Migration[8.1]
  def change
    rename_table :job_applications, :opportunities
  end
end
