class AddChildrenCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :children_count, :integer, null: false, default: 0
  end
end
