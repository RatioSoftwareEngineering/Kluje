class AddPaypalSubscriptionPaymentIdToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :subscription_payment_id, :integer
  end

  def self.down
    remove_column :subscriptions, :subscription_payment_id
  end
end
