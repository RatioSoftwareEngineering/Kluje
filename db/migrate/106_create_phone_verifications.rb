class CreatePhoneVerifications < ActiveRecord::Migration
  def change
    create_table :phone_verifications do |t|
      t.belongs_to :account

      t.string :mobile_number
      t.string :verification_code
      t.datetime :verification_code_expires_at

      t.string :ip

      t.boolean :verified

      t.timestamps
    end
  end
end
