class CreateCountries < ActiveRecord::Migration
  # rubocop:disable Metrics/LineLength
  def change # rubocop:disable Metrics/AbcSize
    create_table :countries do |t|
      t.string :name
      t.string :native_name

      t.string :cca2
      t.string :cca3

      t.string :flag

      t.string :currency_code
      t.string :price_format

      t.string :default_phone_code

      t.boolean :available
    end

    data = File.read("#{Padrino.root}/db/data/countries.json")
    countries = JSON.parse(data)
    countries.each do |country|
      next if Country.find_by_cca2 country['cca2'].downcase
      native = country['name']['native'].first
      native = native ? native.second['common'] : country['name']['common']
      Country.create(
        available: false,
        name: country['name']['common'],
        native_name: native,
        cca2: country['cca2'],
        cca3: country['cca3'],
        remote_flag_url: Rails.env.test? ? nil : "https://s3-ap-southeast-1.amazonaws.com/dev.folr.com/public/flags/#{country['cca3'].downcase}.png",
        currency_code: country['currency'].first,
        price_format: '$%.2f',
        default_phone_code: country['callingCode'].first
      )
    end

    %w(Singapore Indonesia Malaysia).each do |country_name|
      country = Country.find_by_name country_name
      country.update_attributes available: true
    end
  end
end
