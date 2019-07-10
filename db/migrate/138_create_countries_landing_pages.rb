class CreateCountriesLandingPages < ActiveRecord::Migration
  def self.up
    create_table :countries_landing_pages, id: false do |t|
      t.references :country
      t.references :landing_page
    end
    add_index :countries_landing_pages, [:country_id, :landing_page_id]
    add_index :countries_landing_pages, :country_id

    LandingPage.all.each do |page|
      page.countries = Country.available
      page.save
    end
  end

  def self.down
    drop_table :countries_landing_pages
  end
end
