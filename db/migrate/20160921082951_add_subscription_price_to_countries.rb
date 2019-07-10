class AddSubscriptionPriceToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :residential_subscription_price, :decimal, precision: 13, scale: 2, default: 0
    add_column :countries, :commercial_subscription_price, :decimal, precision: 13, scale: 2, default: 0
  end
end
