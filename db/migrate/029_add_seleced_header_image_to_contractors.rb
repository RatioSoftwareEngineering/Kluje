class AddSelecedHeaderImageToContractors < ActiveRecord::Migration
  def self.up
    change_table :contractors do |t|
      t.string :selected_header_image
    end
  end

  def self.down
    change_table :contractors do |t|
      t.remove :selected_header_image
    end
  end
end
