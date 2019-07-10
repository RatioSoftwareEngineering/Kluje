class AddSubscriptionFlagToCountry < ActiveRecord::Migration
  def self.up
    add_column :countries, :subscription_flag, :boolean, default: false
  end

  def self.down
    remove_column :countries, :subscription_flag
  end
end
