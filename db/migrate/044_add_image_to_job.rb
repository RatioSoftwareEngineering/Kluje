class AddImageToJob < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      t.string :image
    end
  end

  def self.down
    change_table :jobs do |t|
      t.remove :image
    end
  end
end
