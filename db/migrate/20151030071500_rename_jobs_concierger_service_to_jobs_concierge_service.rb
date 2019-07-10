class RenameJobsConciergerServiceToJobsConciergeService < ActiveRecord::Migration
  def change
    rename_column :jobs, :concierger_service, :concierge_service
  end
end
