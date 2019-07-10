class ChangeHourToExtraJob < ActiveRecord::Migration
  def change
    change_column :extra_jobs, :hour, :decimal, precision: 5, scale: 2
  end
end
