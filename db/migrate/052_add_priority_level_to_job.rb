class AddPriorityLevelToJob < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      t.integer :priority_level
    end
  end

  def self.down
    change_table :jobs do |t|
      t.remove :priority_level
    end
  end
end
