class CreateFourtyTwoDiscounts < ActiveRecord::Migration
  def self.up
    create_table :fourty_two_discounts do |t|
      t.string :coupon_code
      t.integer :job_id
      t.timestamps
    end
  end

  def self.down
    drop_table :fourty_two_discounts
  end
end
