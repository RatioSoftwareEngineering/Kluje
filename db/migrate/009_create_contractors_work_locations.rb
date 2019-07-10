class CreateContractorsWorkLocations < ActiveRecord::Migration
  def self.up
    create_table :contractors_work_locations do |t|
      t.belongs_to 	:contractor
      t.belongs_to 	:work_location
      t.timestamps
    end
  end

  def self.down
    drop_table :contractors_work_locations
  end
end
