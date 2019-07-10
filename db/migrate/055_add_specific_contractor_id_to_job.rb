class AddSpecificContractorIdToJob < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      t.integer :specific_contractor_id
    end
  end

  def self.down
    change_table :jobs do |t|
      t.remove :specific_contractor_id
    end
  end
end
