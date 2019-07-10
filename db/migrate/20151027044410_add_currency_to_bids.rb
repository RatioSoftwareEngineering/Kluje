class AddCurrencyToBids < ActiveRecord::Migration
  def self.up
    add_column :bids, :currency, :string
    Country.available.each do |country|
      Bid.joins(job: :city).where('cities.country_id = ?', country.id).update_all(currency: country.currency_code)
    end
  end

  def self.down
    remove_column :bids, :currency
  end
end
