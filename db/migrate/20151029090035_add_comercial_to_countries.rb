class AddComercialToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :commercial, :boolean, default: false
  end
end
