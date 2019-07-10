class AddPhotoIdAndBusinessRegistrationToContractors < ActiveRecord::Migration
  def change
    add_column :contractors, :photo_id, :string
    add_column :contractors, :business_registration, :string
  end
end
