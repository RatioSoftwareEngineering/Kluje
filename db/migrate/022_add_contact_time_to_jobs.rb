class AddContactTimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :contact_time_id, :integer, null: false, default: 0
  end
end
