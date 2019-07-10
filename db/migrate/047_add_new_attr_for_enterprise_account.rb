class AddNewAttrForEnterpriseAccount < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.integer :account_id
      t.integer :no_of_account
    end
  end

  def self.down
    change_table :accounts do |t|
      t.integer :account_id
      t.integer :no_of_account
    end
  end
end
