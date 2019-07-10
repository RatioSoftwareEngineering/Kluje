class AddDefaultLocaleToCountries < ActiveRecord::Migration
  def self.up
    add_column :countries, :default_locale, :string, default: 'en'
    Country.find_by_name('Thailand').update_attribute('default_locale', 'th')
  end

  def self.down
    remove_column :countries, :default_locale
  end
end
