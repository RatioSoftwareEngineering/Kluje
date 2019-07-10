class AddNewAttrToExtraJob < ActiveRecord::Migration
  def self.up
    change_table :extra_jobs do |t|
      t.string :coupon_code
      t.string :ref_extra_job_id
      t.integer :hour
      t.text :description
      t.boolean :parts_materials
      t.boolean :is_used
      t.boolean :subscribe_newsletter
    end
  end

  def self.down
    change_table :extra_jobs do |t|
      t.remove :coupon_code
      t.remove :ref_extra_job_id
      t.integer :hour
      t.text :description
      t.boolean :parts_materials
      t.boolean :is_used
      t.boolean :subscribe_newsletter
    end
  end
end
