class AddContractorIdToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.string :contractor_id
    end
  end

  def self.down
    change_table :photos do |t|
      t.remove :contractor_id
    end
  end
end
