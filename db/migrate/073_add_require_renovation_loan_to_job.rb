class AddRequireRenovationLoanToJob < ActiveRecord::Migration
  def self.up
    change_table :jobs do |t|
      t.boolean :require_renovation_loan
    end
  end

  def self.down
    change_table :jobs do |t|
      t.remove :require_renovation_loan
    end
  end
end
