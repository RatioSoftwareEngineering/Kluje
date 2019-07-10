class CreateDealDiscounts < ActiveRecord::Migration
  def self.up
    create_table :deal_discounts do |t|
      t.string :code
      t.decimal :discount
      t.string :prefix
      t.boolean :is_used
      t.timestamps
    end
  end

  def self.down
    drop_table :deal_discounts
  end
end
