class CreateJobViews < ActiveRecord::Migration
  def change
    create_table :job_views do |t|
      t.belongs_to  :job
      t.belongs_to  :contractor

      t.timestamps
    end
  end
end
