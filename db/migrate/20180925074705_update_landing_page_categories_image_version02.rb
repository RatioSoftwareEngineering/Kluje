class UpdateLandingPageCategoriesImageVersion02 < ActiveRecord::Migration
  def change
    [:interior, :exterior, :general].each do |category|
      file = File.open("#{Rails.root}/db/data/images/#{category}_02.png")
      category = LandingPageCategory.find_by(name: category.to_s.capitalize)
      category.update(image: file)
    end
  end
end
