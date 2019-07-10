class AddConciergerServiceToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :concierger_service, :boolean, default: true
  end
end
