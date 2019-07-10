class AddPaypalToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :paypal, :boolean, default: false

    paypal_currencies = [:sgd, :hkd, :php, :thb, :usd]
    Country.where('currency_code in (?)', paypal_currencies).update_all(paypal: true)
  end
end
