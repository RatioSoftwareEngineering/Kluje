class AddDeviseConfirmableFieldsToAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
    end

    Account.where(is_email_verified: '1').find_each do |account|
      account.update_attribute(:confirmed_at, account.created_at)
    end
  end

  def self.down
    remove_column :accounts, :confirmation_token
    remove_column :accounts, :confirmed_at
    remove_column :accounts, :confirmation_sent_at
    remove_column :accounts, :unconfirmed_email
  end
end
