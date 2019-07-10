class AddBudgetToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :budget_value, :decimal, precision: 30, scale: 10
  end

  def self.down
    remove_column :jobs, :budget_value
  end
end
