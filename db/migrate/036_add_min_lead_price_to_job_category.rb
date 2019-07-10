class AddMinLeadPriceToJobCategory < ActiveRecord::Migration
  def self.up
    change_table :job_categories do |t|
      t.decimal :min_lead_price, null: false
    end
  end

  def self.down
    change_table :job_categories do |t|
      t.remove :min_lead_price
    end
  end
end
