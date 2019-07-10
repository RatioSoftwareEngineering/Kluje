class AddRequestCommercialToContractors < ActiveRecord::Migration
  def change
    add_column :contractors, :request_commercial, :boolean
  end
end
