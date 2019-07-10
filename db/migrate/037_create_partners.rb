class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.string :company_name
      t.string :website_url
      t.integer :api_key_id
      t.boolean :is_active
      t.timestamps
    end
  end

  def self.down
    drop_table :partners
  end
end
