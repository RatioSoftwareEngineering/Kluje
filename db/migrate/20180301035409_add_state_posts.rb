class AddStatePosts < ActiveRecord::Migration
  def change
    add_column :posts, :state, :string, null: false, default: :pending, index: true
  end
end
