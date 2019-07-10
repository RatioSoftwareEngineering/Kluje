class AddPropertyAgentIdToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.integer :property_agent_id
    end
  end

  def self.down
    change_table :accounts do |t|
      t.remove :property_agent_id
    end
  end
end
