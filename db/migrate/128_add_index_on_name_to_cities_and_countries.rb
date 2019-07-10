class AddIndexOnNameToCitiesAndCountries < ActiveRecord::Migration
  def change
    add_index :cities, :name
    add_index :countries, :name
  end
end
