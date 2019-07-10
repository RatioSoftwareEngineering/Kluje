class CreateCompanyBrochures < ActiveRecord::Migration
  def change
    create_table :company_brochures do |t|
      t.integer :contractor_id
      t.string :file

      t.timestamps null: false
    end
  end
end
