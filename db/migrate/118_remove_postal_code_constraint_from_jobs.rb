class RemovePostalCodeConstraintFromJobs < ActiveRecord::Migration
  def change
    change_column :jobs, :postal_code, :string, null: true
  end
end
