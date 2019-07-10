class AddCommercialToContractors < ActiveRecord::Migration
  def change
    add_column :contractors, :commercial, :boolean, null: false, default: false
  end
end
