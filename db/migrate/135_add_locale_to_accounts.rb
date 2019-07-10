class AddLocaleToAccounts < ActiveRecord::Migration
  def change
    change_column :accounts, :locale, :string, default: :en
  end
end
