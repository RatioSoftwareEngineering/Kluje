class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :contractor_id
      t.string :permissions
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end
