class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :contractor_id
      t.datetime :expired_at
      t.boolean :auto_reload, default: false
      t.integer :category
      t.string :currency
      t.decimal :price, precision: 13, scale: 2, default: 0.0

      t.timestamps null: false
    end
  end
end
