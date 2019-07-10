class ExpandAmountFields < ActiveRecord::Migration
  def self.up
    change_column :bids, :amount, :decimal, precision: 13, scale: 2
    change_column :credits, :amount, :decimal, precision: 13, scale: 2
    change_column :feature_payments, :amount, :decimal, precision: 13, scale: 2
  end

  def self.down
    change_column :bids, :amount, :decimal, precision: 5, scale: 2
    change_column :credits, :amount, :decimal, precision: 5, scale: 2
    change_column :feature_payments, :amount, :decimal, precision: 5, scale: 2
  end
end
