class CreateFeaturePayments < ActiveRecord::Migration
  def self.up
    create_table :feature_payments do |t|
      t.integer :contractor_id
      t.decimal :amount, precision: 5, scale: 2, null: false
      t.string :feature_name
      t.timestamps
    end
  end

  def self.down
    drop_table :sms_payments
  end
end
