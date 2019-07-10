class DeletePartnerIdToAccount < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :partner_id
  end

  def self.down
    add_column :accounts, :partner_id, :interger
  end
end
