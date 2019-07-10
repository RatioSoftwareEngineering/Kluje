class PopulateLandingPages < ActiveRecord::Migration
  def self.up
    SEO['trade_guide'].each do |trade, seo|
      page = LandingPage.find_or_create_by(slug: trade)
      page.update_attributes title: seo['contractor'],
                             skill: Skill.find_by_id(seo['skill_id']),
                             header: "Find a #{seo['contractor']} in Singapore",
                             description: seo['description'],
                             keywords: seo['keywords'],
                             slug: trade,
                             banner: File.open("#{Padrino.root}/db/data/banners/#{trade}.jpg")
      #        content: '',
    end
  end

  def self.down
  end
end
