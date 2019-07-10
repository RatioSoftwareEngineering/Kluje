class AddQuoterAmountToBids < ActiveRecord::Migration
  def change
    add_column :bids, :amount_quoter, :decimal, precision: 15, scale: 2
  end
end
