class AddCompanyDescriptionToContractor < ActiveRecord::Migration
  def self.up
    change_table :contractors do |t|
      t.text :company_description
    end
  end

  def self.down
    change_table :contractors do |t|
      t.remove :company_description
    end
  end
end
