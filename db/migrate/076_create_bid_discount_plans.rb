class CreateBidDiscountPlans < ActiveRecord::Migration
  def self.up
    create_table :bid_discount_plans do |t|
      t.integer :bid_count
      t.decimal :percentage
      t.integer :month
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :bid_discount_plans
  end
end
