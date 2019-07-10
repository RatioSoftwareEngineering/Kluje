class CreateFacilitiesManagerJobs < ActiveRecord::Migration
  def self.up
    create_table :facilities_manager_jobs do |t|
      t.integer :facilities_manager_id
      t.integer :job_id
      t.string :homeowner_first_name
      t.string :homeowner_last_name
      t.string :homeowner_email
      t.string :homeowner_mobile_number
      t.timestamps
    end
  end

  def self.down
    drop_table :facilities_manager_jobs
  end
end
