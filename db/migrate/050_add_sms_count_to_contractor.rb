class AddSmsCountToContractor < ActiveRecord::Migration
  def self.up
    change_table :contractors do |t|
      t.integer :sms_count
    end
  end

  def self.down
    change_table :contractors do |t|
      t.remove :sms_count
    end
  end
end
