class AddConciergesServicesAmountToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :concierges_service_amount, :decimal, precision: 30, scale: 10, default: 0
  end
end
