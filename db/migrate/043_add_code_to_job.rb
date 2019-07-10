class AddCodeToJob < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      t.string :code
    end
  end

  def self.down
    change_table :jobs do |t|
      t.remove :code
    end
  end
end
