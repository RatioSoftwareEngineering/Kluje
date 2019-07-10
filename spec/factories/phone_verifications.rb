# == Schema Information
#
# Table name: phone_verifications
#
#  id                           :integer          not null, primary key
#  account_id                   :integer
#  mobile_number                :string(255)
#  verification_code            :string(255)
#  verification_code_expires_at :datetime
#  ip                           :string(255)
#  verified                     :boolean
#  created_at                   :datetime
#  updated_at                   :datetime
#

FactoryGirl.define do
  factory :phone_verification do
    mobile_number
  end
end
