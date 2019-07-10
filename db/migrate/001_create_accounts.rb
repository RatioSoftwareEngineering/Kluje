class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string      :first_name, limit: 150
      t.string      :last_name, limit: 150
      t.string      :email
      t.string      :encrypted_password, null: false, default: ''
      t.string      :role
      t.integer     :contractor_id
      t.string      :locale, limit: 5, null: false, default: 'en'

      t.string      :mobile_number, limit: 20
      t.boolean     :subscribe_newsletter, default: true, null: false

      t.string      :reset_password_token
      t.datetime    :reset_password_sent_at

      t.datetime    :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
