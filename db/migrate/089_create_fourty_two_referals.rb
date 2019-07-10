class CreateFourtyTwoReferals < ActiveRecord::Migration
  def self.up
    create_table :fourty_two_referals do |t|
      t.integer :job_id
      t.string :code
      t.integer :ref_job_id
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :fourty_two_referals
  end
end
