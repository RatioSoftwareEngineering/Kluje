class RenameColumnTypeInTableJobsToClientType < ActiveRecord::Migration
  def change
    rename_column :jobs, :type, :client_type
  end
end
