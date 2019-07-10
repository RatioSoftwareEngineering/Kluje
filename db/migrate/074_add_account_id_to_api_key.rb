class AddAccountIdToApiKey < ActiveRecord::Migration
  def self.up
    change_table :api_keys do |t|
      t.integer :account_id
    end
  end

  def self.down
    change_table :api_keys do |t|
      t.remove :account_id
    end
  end
end
