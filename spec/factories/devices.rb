# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  account_id :integer
#  token      :string(255)
#  platform   :string(255)
#  deleted_at :boolean
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  sequence(:token) { |n| "<token number #{n}>" }

  factory :device do
    account
    platform 'IOS'
    token
  end
end
