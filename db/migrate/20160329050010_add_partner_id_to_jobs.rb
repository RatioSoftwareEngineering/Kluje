class AddPartnerIdToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :partner_id, :integer
  end

  def self.down
    remove_column :jobs, :partner_id
  end
end
