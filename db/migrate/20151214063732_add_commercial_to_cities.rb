class AddCommercialToCities < ActiveRecord::Migration
  def change
    add_column :cities, :commercial, :boolean
  end
end
