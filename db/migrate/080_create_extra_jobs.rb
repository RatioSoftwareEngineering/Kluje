class CreateExtraJobs < ActiveRecord::Migration
  def self.up
    create_table :extra_jobs do |t|
      t.integer :job_x_id
      t.decimal :grand_total
      t.boolean :extra_half_an_hour
      t.boolean :extra_an_hour
      t.datetime :deleted_at
      t.string :first_name
      t.string :last_name
      t.string :postal_code
      t.string :email
      t.boolean :is_active
      t.string :mobile_number
      t.timestamps
    end
  end

  def self.down
    drop_table :extra_jobs
  end
end
