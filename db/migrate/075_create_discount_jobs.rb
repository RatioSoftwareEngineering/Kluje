class CreateDiscountJobs < ActiveRecord::Migration
  def self.up
    create_table :discount_jobs do |t|
      t.integer :old_job_id
      t.integer :new_job_id
      t.integer :contractor_id
      t.string :coupon_code
      t.boolean :is_active
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :discount_jobs
  end
end
