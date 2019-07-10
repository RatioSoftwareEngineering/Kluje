class ChangePostalCodeFromContractors < ActiveRecord::Migration
  def change
    change_column :contractors, :company_postal_code, :integer
  end
end
