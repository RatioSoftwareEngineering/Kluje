class AddStateToPremiumPurchases < ActiveRecord::Migration
  def self.up
    add_column :premium_purchases, :state, :string
  end

  def self.down
    remove_column :premium_purchases, :state, :string
  end
end
