class AddCountryIdToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :country_id, :integer

    singapore = Country.find_by_name 'Singapore'
    Account.where(country_id: nil).update_all country_id: singapore.id
  end

  def self.down
    remove_column :accounts, :country_id
  end
end
