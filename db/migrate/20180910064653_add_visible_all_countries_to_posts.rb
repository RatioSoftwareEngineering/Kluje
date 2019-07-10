class AddVisibleAllCountriesToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :visible_all_countries, :boolean, default: true
  end
end
