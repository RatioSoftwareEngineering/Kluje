class CreateJobXes < ActiveRecord::Migration
  def self.up
    create_table :job_xes do |t|
      t.string :name
      t.decimal :job_total
      t.integer :materials
      t.integer :callout
      t.decimal :total
      t.integer :service_id
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :job_xes
  end
end
