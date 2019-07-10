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

FactoryGirl.define do
  factory :city do
    name 'Singapore'
    country_id Country.first
    available true
  end
end
