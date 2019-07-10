class AddDeletedAtToFacilitiesManagerJob < ActiveRecord::Migration
  def self.up
    change_table :facilities_manager_jobs do |t|
      t.datetime :deleted_at
    end
  end

  def self.down
    change_table :facilities_manager_jobs do |t|
      t.remove :deleted_at
    end
  end
end
