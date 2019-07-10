class ChangePostalCodeFromJob < ActiveRecord::Migration
  def change
    change_column :jobs, :postal_code, :string
  end
end
