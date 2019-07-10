class AddLicensesToContractor < ActiveRecord::Migration
  def self.up
    change_table :contractors do |t|
      t.string :pub_license
      t.string :ema_license
      t.string :case_member
      t.string :scal_member
      t.string :bizsafe_member
    end
  end

  def self.down
    change_table :contractors do |t|
      t.remove :pub_license
      t.remove :ema_license
      t.remove :case_member
      t.remove :scal_member
      t.remove :bizsafe_member
    end
  end
end
