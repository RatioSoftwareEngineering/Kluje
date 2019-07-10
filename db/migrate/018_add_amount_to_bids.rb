class AddAmountToBids < ActiveRecord::Migration
  def change
    add_column :bids, :amount, :decimal, precision: 5, scale: 2, after: :contractor_id
    Bid.all.each { |bid| bid.update_attribute(:amount, bid.job.budget.lead_price) }
  end
end
