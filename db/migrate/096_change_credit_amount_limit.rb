class ChangeCreditAmountLimit < ActiveRecord::Migration
  def self.up
    change_column :credits, :amount, :decimal, precision: 6, scale: 2
  end

  def self.down
    change_column :credits, :amount, :decimal, precision: 5, scale: 2
  end
end
