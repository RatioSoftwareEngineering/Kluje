class AddSuspendedAtToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :suspended_at, :datetime, null: true, default: nil
  end
end
