class RemoveBidDiscountPlans < ActiveRecord::Migration
  def change
    rename_table :bid_discount_plans, :_del_bid_discount_plans
  end
end
