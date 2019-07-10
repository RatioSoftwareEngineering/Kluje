# == Schema Information
#
# Table name: landing_pages
#
#  id                       :integer          not null, primary key
#  title                    :string(255)
#  header                   :string(255)
#  description              :string(255)
#  keywords                 :string(255)
#  slug                     :string(255)
#  content                  :text(65535)
#  banner                   :string(255)
#  skill_id                 :integer
#  created_at               :datetime
#  updated_at               :datetime
#  published_at             :datetime
#  landing_page_category_id :integer
#  language                 :string(255)      default("en")
#  visible_all_countries    :boolean          default(TRUE)
#
# Indexes
#
#  index_landing_pages_on_landing_page_category_id  (landing_page_category_id)
#  index_landing_pages_on_language                  (language)
#  index_landing_pages_on_published_at              (published_at)
#

class LandingPage < ActiveRecord::Base
  #  attr_accessible :title, :skill_id, :landing_page_category_id, :slug, :header,
  #                  :content, :banner, :description, :keywords, :language, :country_ids,
  #                  :countries, :published_at

  belongs_to :skill
  belongs_to :landing_page_category
  has_and_belongs_to_many :countries

  mount_uploader :banner, ImageUploader

  before_save do
    self.slug ||= title.try(:parameterize)
  end

  scope :category, ->(category) { where(landing_page_category_id: category.id) }
  scope :language, ->(lang) { where(language: lang) }
  scope :published, -> { where('published_at < ?', Time.zone.now) }
  scope :for_all_country, -> { where(visible_all_countries: true) }

  def published?
    published_at && published_at < Time.zone.now
  end


  def landing_page_url current_locale, current_locale_country
    self.visible_all_countries? ? Rails.application.routes.url_helpers.landing_page_path(locale: current_locale, slug: self.slug) : Rails.application.routes.url_helpers.landing_page_path(locale: current_locale_country, slug: self.slug)
  end
end
