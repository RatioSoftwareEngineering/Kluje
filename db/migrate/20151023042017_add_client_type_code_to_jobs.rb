class AddClientTypeCodeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :client_type_code, :string
  end
end
