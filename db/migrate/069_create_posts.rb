class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.text :meta_keyword
      t.text :meta_description
      t.integer :category_id
      t.string :image
      t.string :author
      t.string :author_google_plus_url
      t.boolean :is_published
      t.datetime :published_at
      t.datetime :deleted_at
      t.string :slug_url
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
