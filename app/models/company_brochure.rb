# == Schema Information
#
# Table name: company_brochures
#
#  id            :integer          not null, primary key
#  contractor_id :integer
#  file          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CompanyBrochure < ActiveRecord::Base
  validates :file, presence: true
  belongs_to :contractor

  mount_uploader :file, DocumentUploader
end
