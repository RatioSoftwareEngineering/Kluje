class AddPersonalCodeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :personal_code, :int
  end
end
