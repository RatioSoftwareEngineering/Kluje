class AddAddressToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :address, :string
  end
end
