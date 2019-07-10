class AddHeaderImageCropAttrToContractor < ActiveRecord::Migration
  def self.up
    change_table :contractors do |t|
      t.string :crop_x
      t.string :crop_y
      t.string :crop_w
      t.string :crop_h
    end
  end

  def self.down
    change_table :contractors do |t|
      t.remove :crop_x
      t.remove :crop_y
      t.remove :crop_w
      t.remove :crop_h
    end
  end
end
