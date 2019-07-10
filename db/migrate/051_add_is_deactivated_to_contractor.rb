class AddIsDeactivatedToContractor < ActiveRecord::Migration
  def self.up
    change_table :contractors do |t|
      t.boolean :is_deactivated
    end
  end

  def self.down
    change_table :contractors do |t|
      t.remove :is_deactivated
    end
  end
end
