class AddPropertyTypeToJob < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      t.string :property_type
    end
  end

  def self.down
    change_table :jobs do |t|
      t.remove :property_type
    end
  end
end
