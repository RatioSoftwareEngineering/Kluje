class AddHomeownerIdToMeeting < ActiveRecord::Migration
  def change
    add_column :meetings, :homeowner_id, :int
  end
end
