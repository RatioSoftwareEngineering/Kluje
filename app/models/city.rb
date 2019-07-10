# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  country_id :integer
#  name       :string(255)
#  available  :boolean
#  commercial :boolean
#
# Indexes
#
#  index_cities_on_name  (name)
#

class City < ActiveRecord::Base
  belongs_to :country
  has_many :jobs
  has_many :homeowners, through: :jobs
  has_and_belongs_to_many :contractors, join_table: 'contractors_cities'

  scope :available, -> { where(available: true) }
  scope :commercial, -> { where(commercial: true) }

  def slug
    name.parameterize.underscore
  end
end
