class AddIndexPublishedAtLandingPageCategoryIdLanguageToLandingPages < ActiveRecord::Migration
  def change
    add_index :landing_pages, :published_at
    add_index :landing_pages, :landing_page_category_id
    add_index :landing_pages, :language
  end
end
