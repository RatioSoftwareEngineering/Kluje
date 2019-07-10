class CreateBudgets < ActiveRecord::Migration
  def self.up
    create_table :budgets do |t|
      t.decimal :start_price, null: false
      t.decimal     :end_price, null: false
      t.decimal     :lead_price, precision: 5, scale: 2, null: false
      t.datetime    :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :budgets
  end
end
