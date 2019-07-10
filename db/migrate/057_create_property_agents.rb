class CreatePropertyAgents < ActiveRecord::Migration
  def self.up
    create_table :property_agents do |t|
      t.string      :company_name, null: false
      t.string      :office_number
      t.string      :cea_number
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :property_agents
  end
end
