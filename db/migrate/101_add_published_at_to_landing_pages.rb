class AddPublishedAtToLandingPages < ActiveRecord::Migration
  def change
    add_column :landing_pages, :published_at, :datetime
  end
end
