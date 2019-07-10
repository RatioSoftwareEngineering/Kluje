class AddCeaNumberToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.string :cea_number
    end
  end

  def self.down
    change_table :accounts do |t|
      t.remove :cea_number
    end
  end
end
