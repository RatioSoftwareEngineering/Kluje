class CreateBudgetsCountries < ActiveRecord::Migration
  def self.up
    create_table :countries_budgets do |t|
      t.belongs_to :country
      t.belongs_to :budget

      t.decimal :start_price, precision: 13, scale: 0
      t.decimal :end_price, precision: 13, scale: 0
      t.decimal :lead_price, precision: 13, scale: 2

      t.timestamps
    end

    singapore = Country.find_by_name 'Singapore'
    Budget.all.each do |budget|
      CountryBudget.create country_id: singapore.id, budget_id: budget.id,
                           start_price: budget.start_price, end_price: budget.end_price,
                           lead_price: budget.lead_price
    end
  end

  def self.down
    drop_table :countries_budgets
  end
end
