class AddFileToBids < ActiveRecord::Migration
  def change
    add_column :bids, :file, :string
  end
end
