# == Schema Information
#
# Table name: subscriptions
#
#  id                      :integer          not null, primary key
#  contractor_id           :integer
#  expired_at              :datetime
#  auto_reload             :boolean          default(FALSE)
#  category                :integer
#  currency                :string(255)
#  price                   :decimal(13, 2)   default(0.0)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  subscription_payment_id :integer
#

FactoryGirl.define do
  factory :subscription do
    contractor { create :contractor }
    expired_at Time.zone.now + 3.days
    auto_reload true
    category 1
    currency 'sgd'
    price 250
  end
end
