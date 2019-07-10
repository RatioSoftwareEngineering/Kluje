class AddDefaultValueToJob < ActiveRecord::Migration
  def change
    change_column_default :jobs, :number_of_quote, 0
  end
end
