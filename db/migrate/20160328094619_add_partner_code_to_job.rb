class AddPartnerCodeToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :partner_code, :string
  end

  def self.down
    remove_column :jobs, :partner_code
  end
end
