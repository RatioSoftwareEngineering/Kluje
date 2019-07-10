class AddSmsBundlePriceToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :sms_bundle_price, :decimal, precision: 13, scale: 2, default: 9.99
  end
end
