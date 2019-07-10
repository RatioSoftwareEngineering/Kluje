class AddPaymentTypeToPaypalPayments < ActiveRecord::Migration
  def self.up
    add_column :paypal_payments, :payment_type, :integer, null: false
  end

  def self.down
    remove_column :paypal_payments, :payment_type
  end
end
