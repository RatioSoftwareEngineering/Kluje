class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.belongs_to :country
      t.string :name
      t.boolean :available
    end

    countries_cities = {
      'Singapore' => ['Singapore'],
      'Malaysia' => %w(Selangor Penang Johor),
      'Indonesia' => ['Jakarta']
    }

    countries_cities.each do |country_name, cities|
      country = Country.find_by(name: country_name)
      cities.each do |city_name|
        City.find_or_create_by(country_id: country.id, name: city_name)
      end
    end

    # Default enable Singapore
    ['Singapore'].each do |city_name|
      city = City.find_by_name city_name
      city.update_attributes available: true
    end
  end
end
