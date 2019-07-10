class AddPlaceToMeeting < ActiveRecord::Migration
  def change
    add_column :meetings, :place, :string
    add_column :meetings, :date, :date
    add_column :meetings, :time, :time
  end
end
