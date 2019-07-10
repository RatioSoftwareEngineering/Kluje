# == Schema Information
#
# Table name: countries_budgets
#
#  id          :integer          not null, primary key
#  country_id  :integer
#  budget_id   :integer
#  start_price :decimal(13, )
#  end_price   :decimal(13, )
#  lead_price  :decimal(13, 2)
#  created_at  :datetime
#  updated_at  :datetime
#

class CountryBudget < ActiveRecord::Base
  self.table_name = 'countries_budgets'

  belongs_to :country
  belongs_to :budget

  def range
    start_price && end_price && country_id && \
      "#{comma_numbers(country.price_format % start_price)} - #{comma_numbers(country.price_format % end_price)}"
  end

  def comma_numbers(number, delimiter = ',')
    number.to_s.reverse.gsub(/([0-9]{3}(?=([0-9])))/, "\\1#{delimiter}").reverse
  end

  def singapore_budget
    budget && budget.pretty
  end

  def as_json(options = {})
    super.merge(range: range)
  end
end
