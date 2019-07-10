class CreateRevenues < ActiveRecord::Migration
  def change
    create_table :revenues do |t|
      t.datetime :time
      t.float :amount
      t.integer :country_id

      t.timestamps null: false
    end
  end
end
