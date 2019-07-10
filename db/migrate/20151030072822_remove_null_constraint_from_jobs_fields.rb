class RemoveNullConstraintFromJobsFields < ActiveRecord::Migration
  def change
    change_column :jobs, :job_category_id, :integer, null: true
    change_column :jobs, :skill_id, :integer, null: true
    change_column :jobs, :availability_id, :integer, null: true
  end
end
