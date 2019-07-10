class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :sender_id
      t.string :sender_type
      t.integer :recipient_id
      t.string :recipient_type
      t.integer :job_id

      t.decimal :amount, precision: 15, scale: 2
      t.string :currency
      t.string :number
      t.string :file

      t.boolean :paid

      t.timestamps
    end
  end
end
