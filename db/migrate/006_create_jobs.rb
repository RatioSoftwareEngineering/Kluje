class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer     :homeowner_id
      t.integer     :contractor_id
      t.integer     :job_category_id, null: false
      t.integer     :skill_id, null: false
      t.integer     :work_location_id, null: false
      t.integer     :budget_id, null: false
      t.text        :description, null: false
      t.integer     :availability_id, null: false
      t.integer     :postal_code, null: false
      t.decimal     :lat, precision: 15, scale: 10
      t.decimal     :lng, precision: 15, scale: 10
      t.string      :state, default: 'pending'

      t.datetime    :purchased_at
      t.datetime    :approved_at
      t.datetime    :deleted_at
      t.timestamps
    end

    add_index :jobs, :state
  end
end
