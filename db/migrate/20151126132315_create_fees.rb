class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.integer :country_id
      t.integer :commission, default: 10
      t.decimal :concierge, default: 0

      t.timestamps null: false
    end
  end
end
