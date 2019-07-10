class BoostedPayment < ActiveRecord::Migration
  def self.up
    create_table :boosted_payments do |t|
      t.decimal :amount
      t.integer :account_id
      t.timestamps
    end
  end

  def self.down
    drop_table :boosted_payments
  end
end
