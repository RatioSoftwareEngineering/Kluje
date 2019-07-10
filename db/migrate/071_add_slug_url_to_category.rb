class AddSlugUrlToCategory < ActiveRecord::Migration
  def self.up
    change_table :categories do |t|
      t.string :slug_url
    end
  end

  def self.down
    change_table :categories do |t|
      t.remove :slug_url
    end
  end
end
