class RemovePlanFromContractor < ActiveRecord::Migration
  def change
    remove_column :contractors, :plan_id
  end
end
