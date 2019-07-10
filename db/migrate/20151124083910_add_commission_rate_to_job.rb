class AddCommissionRateToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :commission_rate, :decimal, precision: 30, scale: 10, default: 5
  end
end
