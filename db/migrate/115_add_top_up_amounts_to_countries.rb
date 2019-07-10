class AddTopUpAmountsToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :top_up_amounts, :text
  end
end
