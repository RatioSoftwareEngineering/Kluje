class CreateWorkLocations < ActiveRecord::Migration
  def self.up
    create_table :work_locations do |t|
      t.string	:name, null: false

      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :work_locations
  end
end
