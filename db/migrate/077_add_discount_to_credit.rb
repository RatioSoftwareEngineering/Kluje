class AddDiscountToCredit < ActiveRecord::Migration
  def self.up
    change_table :credits do |t|
      t.decimal :discount
    end
  end

  def self.down
    change_table :credits do |t|
      t.remove :discount
    end
  end
end
