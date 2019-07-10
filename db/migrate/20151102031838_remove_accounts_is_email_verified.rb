class RemoveAccountsIsEmailVerified < ActiveRecord::Migration
  def self.up
    Account.where("is_email_verified = '1'").find_each do |a|
      a.update_attribute(:confirmed_at, a.created_at || Time.now)
    end
    remove_column :accounts, :is_email_verified
  end

  def self.down
    add_column :accounts, :is_email_verified, :string
  end
end
