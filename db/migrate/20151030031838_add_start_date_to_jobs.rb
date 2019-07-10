class AddStartDateToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :start_date, :datetime
  end
end
