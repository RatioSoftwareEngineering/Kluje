class UpdateOldAvailabilities < ActiveRecord::Migration
  def change
    Job.where(availability_id: 1).update_all(availability_id: 8)
    Job.where(availability_id: 2).update_all(availability_id: 3)
    Job.where(availability_id: 4).update_all(availability_id: 5)
  end
end
