class AddPostalCodesToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :postal_codes, :boolean, default: true
  end
end
