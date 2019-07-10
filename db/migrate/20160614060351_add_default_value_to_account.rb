class AddDefaultValueToAccount < ActiveRecord::Migration
  def change
    change_column :accounts, :encrypted_password, :string, default: '', null: false
  end
end
