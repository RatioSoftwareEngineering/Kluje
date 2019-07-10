class ChangeCommisionRateToJobs < ActiveRecord::Migration
  def self.up
    change_column :jobs, :commission_rate, :integer, null: false, default: 10
  end

  def self.down
    change_column :jobs, :commission_rate, :decimal, null: false, default: 10
  end
end
