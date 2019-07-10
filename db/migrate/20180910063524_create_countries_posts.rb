class CreateCountriesPosts < ActiveRecord::Migration
  def change
    create_table :countries_posts do |t|
      t.references :country
      t.references :post

      t.timestamps
    end

    add_index :countries_posts, [:country_id, :post_id]
    add_index :countries_posts, :country_id
  end
end
