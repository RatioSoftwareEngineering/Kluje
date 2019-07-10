class CreateWaitingLists < ActiveRecord::Migration
  def change
    create_table :waiting_lists do |t|
      t.integer :contractor_id, null: false

      t.timestamps null: false
    end
  end
end
