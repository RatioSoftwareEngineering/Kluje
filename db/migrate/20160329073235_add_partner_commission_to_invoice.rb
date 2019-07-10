class AddPartnerCommissionToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :unpaid_partner_commission, :boolean, default: false
  end

  def self.down
    remove_column :invoices, :unpaid_partner_commission
  end
end
