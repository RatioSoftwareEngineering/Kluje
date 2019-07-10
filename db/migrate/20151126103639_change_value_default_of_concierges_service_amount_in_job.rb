class ChangeValueDefaultOfConciergesServiceAmountInJob < ActiveRecord::Migration
  def change
    change_column :jobs, :concierges_service_amount, :decimal, default: 20
  end
end
