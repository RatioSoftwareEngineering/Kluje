class AddAgentToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :agent, :boolean
  end
end
