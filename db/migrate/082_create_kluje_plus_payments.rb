class CreateKlujePlusPayments < ActiveRecord::Migration
  def self.up
    create_table :kluje_plus_payments do |t|
      t.integer :txn_id
      t.string :txn_type
      t.decimal :amount
      t.decimal :fee
      t.string :currency
      t.string :status
      t.string :type
      t.text :params
      t.integer :job_x_id
      t.integer :account_id
      t.timestamps
    end
  end

  def self.down
    drop_table :kluje_plus_payments
  end
end
