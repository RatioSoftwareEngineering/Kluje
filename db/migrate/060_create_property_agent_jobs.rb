class CreatePropertyAgentJobs < ActiveRecord::Migration
  def self.up
    create_table :property_agent_jobs do |t|
      t.integer :property_agent_id
      t.integer :job_id
      t.string :homeowner_first_name
      t.string :homeowner_last_name
      t.string :homeowner_email
      t.string :homeowner_mobile_number
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :property_agent_jobs
  end
end
