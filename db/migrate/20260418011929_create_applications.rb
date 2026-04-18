class CreateApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :job_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_name, null: false
      t.text :job_description, null: false
      t.text :generated_typst
      t.boolean :job_description_truncated, default: false, null: false

      t.timestamps
    end
  end
end
