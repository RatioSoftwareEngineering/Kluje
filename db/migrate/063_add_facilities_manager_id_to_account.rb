class AddFacilitiesManagerIdToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.integer :facilities_manager_id
    end
  end

  def self.down
    change_table :accounts do |t|
      t.remove :facilities_manager_id
    end
  end
end
