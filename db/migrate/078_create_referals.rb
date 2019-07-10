class CreateReferals < ActiveRecord::Migration
  def self.up
    create_table :referals do |t|
      t.string :code
      t.string :name
      t.decimal :amount
      t.integer :job_id
      t.integer :contractor_id
      t.integer :account_id
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :referals
  end
end
