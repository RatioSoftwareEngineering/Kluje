class ChangeJobCategoriesMinLeadPriceToMinBudget < ActiveRecord::Migration
  def self.up
    rename_column :job_categories, :min_lead_price, :min_budget
    add_column :job_categories, :max_budget, :decimal, precision: 10, scale: 0

    incorrect_budgets = Budget.with_deleted.where('end_price < start_price')
    incorrect_budgets.each do |budget|
      budget.jobs.update_all(budget_id: budget.id - 1)
      budget.delete
    end

    JobCategory.all.each do |job_category|
      budgets = Budget.where('end_price > ?', job_category.min_budget).order('start_price ASC')
      if budgets.present?
        last_budget = budgets[7] || budgets.last
        job_category.update_attributes(max_budget: last_budget.end_price)
      end
    end
  end

  def self.down
    remove_column :job_categories, :max_budget
    rename_column :job_categories, :min_budget, :min_lead_price
  end
end
