class AddDefaultValueForQuoterAmountInBids < ActiveRecord::Migration
  def change
    change_column :bids, :amount_quoter, :decimal, default: 0
  end
end
