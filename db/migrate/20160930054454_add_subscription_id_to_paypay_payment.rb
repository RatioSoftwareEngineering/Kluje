class AddSubscriptionIdToPaypayPayment < ActiveRecord::Migration
  def self.up
    add_column :paypal_payments, :subscription_id, :string
  end

  def self.down
    remove_column :paypal_payments, :subscription_id
  end
end
