class AddEmailVerificationCodeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :email_verification_code, :string
  end
end
