class CreateJobCategories < ActiveRecord::Migration
  def self.up
    create_table :job_categories do |t|
      t.string      :name, null: false
      t.text        :description
      t.integer     :skill_id, null: false
      t.datetime    :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :job_categories
  end
end
