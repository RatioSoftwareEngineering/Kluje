# == Schema Information
#
# Table name: photos
#
#  id            :integer          not null, primary key
#  image_name    :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  contractor_id :string(255)
#  job_id        :string(255)
#

class Photo < ActiveRecord::Base
  mount_uploader :image_name, PhotoUploader
  belongs_to :contractor
  belongs_to :job
  attr_accessible :image_name, :contractor_id, :job_id

  def image?
    image_name_url.present? && self[:image_name].downcase =~ /jpg|jpeg|gif|png/
  end

  def document?
    image_name_url.present? && !image?
  end
end
