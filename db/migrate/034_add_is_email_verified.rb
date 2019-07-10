class AddIsEmailVerified < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.string :is_email_verified
    end
    # Account.all.each do |account|
    #   account.is_email_verified = true
    #   account.save
    # end
  end

  def self.down
    change_table :accounts do |t|
      t.remove :is_email_verified
    end
  end
end
