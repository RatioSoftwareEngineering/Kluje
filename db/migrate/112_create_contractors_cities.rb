class CreateContractorsCities < ActiveRecord::Migration
  def change
    create_table :contractors_cities do |t|
      t.belongs_to :contractor
      t.belongs_to :city

      t.timestamps
    end

    Contractor.all.each do |contractor|
      account = contractor.account
      next unless account

      if account.country.nil?
        account.country = Country.find_by_name('Singapore')
        account.save
      end
      account.country.cities.each do |city|
        ContractorsCity.create city_id: city.id, contractor_id: contractor.id
      end
    end
  end
end
