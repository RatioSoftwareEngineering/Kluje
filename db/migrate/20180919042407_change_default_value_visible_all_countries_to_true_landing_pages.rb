class ChangeDefaultValueVisibleAllCountriesToTrueLandingPages < ActiveRecord::Migration
  def change
    change_column_default :landing_pages, :visible_all_countries, true
  end
end
