class AddRefCodeToJob < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      t.string :ref_code
    end
  end

  def self.down
    change_table :jobs do |t|
      t.remove :ref_code
    end
  end
end
