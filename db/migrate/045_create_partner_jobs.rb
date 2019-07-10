class CreatePartnerJobs < ActiveRecord::Migration
  def self.up
    create_table :partner_jobs do |t|
      t.integer :partner_id
      t.integer :job_id
      t.timestamps
    end
  end

  def self.down
    drop_table :partner_jobs
  end
end
