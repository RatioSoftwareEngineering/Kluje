class AddDurationToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :duration, :integer, default: 30
  end
end
