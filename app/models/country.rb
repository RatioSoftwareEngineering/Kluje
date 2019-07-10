# == Schema Information
#
# Table name: countries
#
#  id                             :integer          not null, primary key
#  name                           :string(255)
#  native_name                    :string(255)
#  cca2                           :string(255)
#  cca3                           :string(255)
#  flag                           :string(255)
#  currency_code                  :string(255)
#  price_format                   :string(255)
#  default_phone_code             :string(255)
#  available                      :boolean
#  time_zone                      :string(255)
#  top_up_amounts                 :text(65535)
#  sms_bundle_price               :decimal(13, 2)   default(9.99)
#  postal_codes                   :boolean          default(TRUE)
#  paypal                         :boolean          default(FALSE)
#  braintree                      :boolean          default(FALSE)
#  default_locale                 :string(255)      default("en")
#  commercial                     :boolean          default(FALSE)
#  residential_subscription_price :decimal(13, 2)   default(0.0)
#  commercial_subscription_price  :decimal(13, 2)   default(0.0)
#  subscription_flag              :boolean          default(FALSE)
#
# Indexes
#
#  index_countries_on_name  (name)
#

class Country < ActiveRecord::Base
  serialize :top_up_amounts, Array

  mount_uploader :flag, PhotoUploader

  before_validation :downcase_codes

  has_many :cities
  has_many :budgets, class_name: 'CountryBudget'
  has_many :accounts
  has_many :jobs, through: :cities
  has_and_belongs_to_many :landing_pages
  has_one :fee
  has_many :revenues, dependent: :destroy


  has_and_belongs_to_many :posts

  scope :available, -> { where(available: true) }
  scope :commercial, -> { where(commercial: true) }

  accepts_nested_attributes_for :budgets

  def self.countries_table
    cities_index_by_country_id = City.available.group_by(&:country_id)
    countries = Country.available.map do |country|
      available_cities = cities_index_by_country_id[country.id]

      cities = []
      cities = available_cities.map { |c| [c.id, FastGettext._(c.name)] } unless available_cities.blank?
      [country.id, { name: FastGettext._(country.name), cities: Hash[cities] }]
    end
    Hash[countries].to_json
  end

  def self.commercial_countries_table
    cities_index_by_country_id = City.commercial.available.group_by(&:country_id)
    countries = Country.commercial.available.map do |country|
      commercial_available_cities = cities_index_by_country_id[country.id]
      
      cities = []
      cities = commercial_available_cities.map { |c| [c.id, FastGettext._(c.name)] } unless commercial_available_cities.blank?

      [country.id, { name: FastGettext._(country.name), cities: Hash[cities] }]
    end
    Hash[countries].to_json
  end

  def formatted_price(amount)
    price_format % amount
  end

  def formatted_sms_bundle_price
    formatted_price(sms_bundle_price)
  end

  def downcase_codes
    cca2.downcase!
    cca3.downcase!
    currency_code.try(:downcase!)
  end

  def top_up_amounts_raw
    top_up_amounts.join(',') unless top_up_amounts.nil?
  end

  def top_up_amounts_raw=(values)
    self.top_up_amounts = []
    self.top_up_amounts = values.split(',').map(&:to_i)
  end

  def get_landing_pages
    landing_page_ids = self.landing_pages.pluck(:id) | LandingPage.for_all_country.pluck(:id)

    landing_pages = LandingPage.where(id: landing_page_ids)
  end
    

  def blogs
    blog_ids = self.posts.where(post_type: :blog).pluck(:id) | Blog.for_all_country.pluck(:id)
    blogs = Blog.where(id: blog_ids)
  end

end
