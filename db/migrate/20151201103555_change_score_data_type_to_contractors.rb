class ChangeScoreDataTypeToContractors < ActiveRecord::Migration
  def self.up
    change_column :contractors, :score, :integer
  end

  def self.down
    change_column :contractors, :score, precision: 5, scale: 2
  end
end
