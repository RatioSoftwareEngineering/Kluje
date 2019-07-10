class ChangeMobileNoFromAccount < ActiveRecord::Migration
  def change
    change_column :accounts, :mobile_number, :string
  end
end
