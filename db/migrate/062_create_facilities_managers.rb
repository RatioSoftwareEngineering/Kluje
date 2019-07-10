class CreateFacilitiesManagers < ActiveRecord::Migration
  def self.up
    create_table :facilities_managers do |t|
      t.string :company_name
      t.string :office_number
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :facilities_managers
  end
end
