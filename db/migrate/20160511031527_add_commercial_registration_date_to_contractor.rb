class AddCommercialRegistrationDateToContractor < ActiveRecord::Migration
  def self.up
    add_column :contractors, :commercial_registration_date, :datetime
  end

  def self.down
    remove_column :contractors, :commercial_registration_date
  end
end
