class CreateRepostJobs < ActiveRecord::Migration
  def self.up
    create_table :repost_jobs do |t|
      t.integer :old_job_id
      t.integer :new_job_id
      t.timestamps
    end
  end

  def self.down
    drop_table :repost_jobs
  end
end
