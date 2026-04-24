class AddToneToOpportunities < ActiveRecord::Migration[8.1]
  def change
    add_column :opportunities, :tone, :string
  end
end
