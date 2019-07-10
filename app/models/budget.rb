# == Schema Information
#
# Table name: budgets
#
#  id          :integer          not null, primary key
#  start_price :decimal(10, )    not null
#  end_price   :decimal(10, )    not null
#  lead_price  :decimal(5, 2)    not null
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Budget < ActiveRecord::Base
  acts_as_paranoid

  has_many :jobs

  def local(country)
    CountryBudget.find_by_budget_id_and_country_id(id, country.id)
  end

  def range
    "$#{comma_numbers(start_price)} - $#{comma_numbers(end_price)}"
  end

  def comma_numbers(number, delimiter = ',')
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{delimiter}").reverse
  end

  def pretty
    "#{range} ($#{comma_numbers(lead_price)})"
  end

  def as_json(options = {})
    super.merge(range: range)
  end
end
