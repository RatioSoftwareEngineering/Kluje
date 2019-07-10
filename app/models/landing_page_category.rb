# == Schema Information
#
# Table name: landing_page_categories
#
#  id    :integer          not null, primary key
#  name  :string(255)
#  image :string(255)
#

class LandingPageCategory < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  has_many :landing_pages
end
