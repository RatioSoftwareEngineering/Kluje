class AddCsToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :commission, :integer
    add_column :invoices, :concierge, :decimal
  end
end
