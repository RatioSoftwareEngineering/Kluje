class ChangePostalCodeFromContractor < ActiveRecord::Migration
  def change
    change_column :contractors, :company_postal_code, :string
  end
end
