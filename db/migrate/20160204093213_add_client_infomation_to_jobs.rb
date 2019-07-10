class AddClientInfomationToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :client_first_name, :string, limit: 150
    add_column :jobs, :client_last_name, :string, limit: 150
    add_column :jobs, :client_email, :string
    add_column :jobs, :client_mobile_number, :string, limit: 20
  end
end
