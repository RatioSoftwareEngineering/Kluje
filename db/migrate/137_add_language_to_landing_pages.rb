class AddLanguageToLandingPages < ActiveRecord::Migration
  def change
    add_column :landing_pages, :language, :string, default: 'en'
  end
end
