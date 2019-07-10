class AddPartnerIdToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.integer :partner_id
    end
  end

  def self.down
    change_table :accounts do |t|
      t.remove :partner_id
    end
  end
end
