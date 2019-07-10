class CreateJobBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.belongs_to  :job
      t.belongs_to  :contractor

      t.timestamps
    end
  end
end
