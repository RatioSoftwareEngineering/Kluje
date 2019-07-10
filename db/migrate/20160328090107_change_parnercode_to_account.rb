class ChangeParnercodeToAccount < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :personal_code
    add_column :accounts, :partner_code, :string
  end

  def self.down
    add_column :accounts, :personal_code, :interger
    remove_column :accounts, :partner_code
  end
end
