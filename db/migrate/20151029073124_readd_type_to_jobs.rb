class ReaddTypeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :type, :string, default: 'Residential::Job'
  end
end
