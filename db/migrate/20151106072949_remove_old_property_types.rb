class RemoveOldPropertyTypes < ActiveRecord::Migration
  def change
    Residential::Job.where(property_type: 1).update_all(property_type: 3)
    Residential::Job.where(property_type: 2).update_all(property_type: 3)
    Residential::Job.where(property_type: 4).update_all(property_type: 6)
    Residential::Job.where(property_type: 5).update_all(property_type: 6)
    Residential::Job.where(property_type: 7).update_all(property_type: 11)
  end
end
