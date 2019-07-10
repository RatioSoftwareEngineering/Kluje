class AddCountryIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :country_id, :integer, index: true, foreign_key: true
  end
end
