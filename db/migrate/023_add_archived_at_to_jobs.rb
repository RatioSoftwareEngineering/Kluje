class AddArchivedAtToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :archived_at, :datetime, null: true, default: nil
  end
end
