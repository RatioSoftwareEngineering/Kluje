class RemoveDefaultCityIdFromJobs < ActiveRecord::Migration
  def change
    change_column_default :jobs, :city_id, nil
  end
end
