# == Schema Information
#
# Table name: fees
#
#  id         :integer          not null, primary key
#  country_id :integer
#  commission :integer          default(10)
#  concierge  :decimal(10, )    default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Fee < ActiveRecord::Base
  validates :commission, presence: true
  validates :concierge, presence: true

  belongs_to :country

  PARTNER_COMMISSION_RATE = 0.02
end
