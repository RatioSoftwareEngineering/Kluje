class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.belongs_to :job, null: false
      t.belongs_to :contractor, null: false

      t.integer :professionalism, default: 0, null: false
      t.integer :quality, default: 0, null: false
      t.integer :value, default: 0, null: false
      t.text :comments

      t.decimal :score, precision: 5, scale: 2

      t.datetime :approved_at
      t.timestamps
    end
  end
end
