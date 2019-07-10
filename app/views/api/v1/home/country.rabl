object @country

attributes :id, :name, :native_name, :cca2, :cca3, :currency_code, :price_format,
           :default_phone_code

node :flag do |country|
  country.flag.url
end

node :cities do |country|
  country.cities.available.map{|c| {id: c.id, name: c.name}}
end
