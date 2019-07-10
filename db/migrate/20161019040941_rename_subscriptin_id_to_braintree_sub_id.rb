class RenameSubscriptinIdToBraintreeSubId < ActiveRecord::Migration
  def change
    rename_column :paypal_payments, :subscription_id, :braintree_subscription_id
  end
end
