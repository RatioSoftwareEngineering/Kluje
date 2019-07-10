class ChangeColumnDefaultBudgetIdInJobs < ActiveRecord::Migration
  def change
    change_column :jobs, :budget_id, :int, null: true
  end
end
