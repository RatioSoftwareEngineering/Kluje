# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#  slug_url   :string(255)
#

class Category < ActiveRecord::Base
  acts_as_paranoid
  has_many :post_categories
  has_many :posts, through: :post_categories
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, message: '%{value} already exit.' }
  before_save do
    self.slug_url = name.parameterize
  end
end
