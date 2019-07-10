class RemovePremiumPurchases < ActiveRecord::Migration
  def self.up
    drop_table :premium_purchases
  end

  def self.down
    create_table :premium_purchases do |t|
      t.belongs_to :contractor

      t.string :txn_type
      t.decimal :amount, precision: 5, scale: 2
      t.string :currency

      t.timestamps
    end
  end
end
