class AddColunmToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :job_id, :int
    add_column :meetings, :contractor_id, :int
  end
end
