class CreateLandingPageCategories < ActiveRecord::Migration
  def change
    create_table :landing_page_categories do |t|
      t.string :name
      t.string :image
    end

    add_column :landing_pages, :landing_page_category_id, :integer

    [:interior, :exterior, :general].each do |category|
      file = File.open("#{Rails.root}/db/data/images/#{category}.png")
      LandingPageCategory.create(name: category.to_s.capitalize, image: file)
    end
  end
end
