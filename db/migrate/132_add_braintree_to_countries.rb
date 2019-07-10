class AddBraintreeToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :braintree, :boolean, default: false

    braintree_currencies = [:sgd, :hkd, :idr, :myr, :php, :thb, :vnd]
    Country.where('currency_code in (?)', braintree_currencies).update_all(braintree: true)
  end
end
