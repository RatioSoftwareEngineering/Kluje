class AddVisibleAllCountriesToLandingPages < ActiveRecord::Migration
  def change
    add_column :landing_pages, :visible_all_countries, :boolean, default: false
  end
end
