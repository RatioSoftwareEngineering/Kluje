class CreateCompanyProjects < ActiveRecord::Migration
  def change
    create_table :company_projects do |t|
      t.integer :contractor_id
      t.string :file

      t.timestamps null: false
    end
  end
end
