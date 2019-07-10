class RemoveNullConstraintFromJobs < ActiveRecord::Migration
  def change
    change_column :jobs, :work_location_id, :integer, null: true
  end
end
