class ExpandAmountFieldForPaypalPayments < ActiveRecord::Migration
  def self.up
    change_column :paypal_payments, :amount, :decimal, precision: 13, scale: 2
    change_column :paypal_payments, :fee, :decimal, precision: 12, scale: 2
  end

  def self.down
    change_column :paypal_payments, :amount, :decimal, precision: 5, scale: 2
    change_column :paypal_payments, :fee, :decimal, precision: 5, scale: 2
  end
end
