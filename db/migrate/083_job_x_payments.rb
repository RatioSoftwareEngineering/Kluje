class JobXPayments < ActiveRecord::Migration
  def self.up
    create_table :job_x_payments do |t|
      t.decimal :amount
      t.integer :job_x_id
      t.timestamps
    end
  end

  def self.down
    drop_table :job_x_payments
  end
end
