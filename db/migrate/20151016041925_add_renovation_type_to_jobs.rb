class AddRenovationTypeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :renovation_type, :int
  end
end
