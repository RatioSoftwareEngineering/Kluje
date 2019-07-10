class AddNewAttrToPartner < ActiveRecord::Migration
  def self.up
    change_table :partners do |t|
      t.boolean :is_iframe
      t.boolean :is_widget
    end
  end

  def self.down
    change_table :partners do |t|
      t.boolean :is_iframe
      t.boolean :is_widget
    end
  end
end
