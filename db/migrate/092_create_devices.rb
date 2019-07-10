class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.integer :account_id
      t.string :token
      t.string :platform
      t.boolean :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
