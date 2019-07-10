class AddOfficeNumberToContractor < ActiveRecord::Migration
  def self.up
    change_table :contractors do |t|
      t.string :office_number
    end
  end

  def self.down
    change_table :contractors do |t|
      t.remove :office_number
    end
  end
end
