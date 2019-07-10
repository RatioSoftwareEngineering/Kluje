class ChangeRequestCommercialToContractor < ActiveRecord::Migration
  def change
    remove_column :contractors, :request_commercial
    add_column :contractors, :request_commercial, :boolean, default: false
  end
end
