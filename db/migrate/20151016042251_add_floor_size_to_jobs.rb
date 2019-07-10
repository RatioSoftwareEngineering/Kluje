class AddFloorSizeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :floor_size, :int
  end
end
