class ChangeUnpaidPartnerCommisionToInvoice < ActiveRecord::Migration
  def self.up
    remove_column :invoices, :unpaid_partner_commission
    add_column :invoices, :partner_commission, :integer, default: 0
  end

  def self.down
    remove_column :invoices, :partner_commission
    add_column :invoices, :unpaid_partner_commission, :boolean, default: false
  end
end
