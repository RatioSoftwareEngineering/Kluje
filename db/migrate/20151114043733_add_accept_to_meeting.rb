class AddAcceptToMeeting < ActiveRecord::Migration
  def change
    add_column :meetings, :accept, :boolean
  end
end
