class ChangeMobileNoFromAccounts < ActiveRecord::Migration
  def change
    change_column :accounts, :mobile_number, :integer
  end
end
