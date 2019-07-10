class AddTimeZoneToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :time_zone, :string
  end
end
