class AddDeletedAtToPartner < ActiveRecord::Migration
  def self.up
    change_table :partners do |t|
      t.datetime :deleted_at
    end
  end

  def self.down
    change_table :partners do |t|
      t.remove :deleted_at
    end
  end
end
