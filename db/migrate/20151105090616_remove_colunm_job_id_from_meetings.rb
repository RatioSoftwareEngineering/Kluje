class RemoveColunmJobIdFromMeetings < ActiveRecord::Migration
  def change
    remove_column :meetings, :job_id
    remove_column :meetings, :contractor_id
  end
end
