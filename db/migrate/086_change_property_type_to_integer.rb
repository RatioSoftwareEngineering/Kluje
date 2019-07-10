class ChangePropertyTypeToInteger < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      t.change :property_type, :integer
    end
  end

  def self.down
    change_table :jobs do |t|
      t.change :property_type, :integer
    end
  end
end
