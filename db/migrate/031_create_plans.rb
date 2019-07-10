class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string  :name
      t.decimal :price, precision: 6, scale: 2, null: false
      t.integer :skills_limit
    end
  end
end
