class NormalizePhoneNumbers < ActiveRecord::Migration
  def self.up
    Account.all.each(&:save)
  end

  def self.down
    Account.all.each do |account|
      next unless account.mobile_number
      account.mobile_number_will_change!
      account.mobile_number.gsub!(/^\+?65/, '')
      account.save
    end
  end
end
