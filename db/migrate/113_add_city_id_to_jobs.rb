class AddCityIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :city_id, :integer, default: City.find_by_name('Singapore')
  end
end
