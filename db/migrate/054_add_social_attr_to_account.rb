class AddSocialAttrToAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.string :uid
      t.string :provider
    end
  end

  def self.down
    change_table :accounts do |t|
      t.remove :uid
      t.remove :provider
    end
  end
end
