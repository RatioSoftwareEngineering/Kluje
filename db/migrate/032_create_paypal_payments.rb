class CreatePaypalPayments < ActiveRecord::Migration
  def change
    create_table :paypal_payments do |t|
      t.belongs_to  :contractor
      t.belongs_to  :membership

      t.string      :txn_id
      t.string      :txn_type
      t.decimal     :amount, precision: 5, scale: 2
      t.decimal     :fee, precision: 5, scale: 2
      t.string      :currency
      t.string      :status

      t.string      :type

      t.timestamps

      t.text :params
    end
  end
end
