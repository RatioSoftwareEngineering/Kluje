# == Schema Information
#
# Table name: credits
#
#  id            :integer          not null, primary key
#  contractor_id :integer
#  amount        :decimal(13, 2)   not null
#  deposit_type  :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  discount      :decimal(10, )
#  currency      :string(255)      default("sgd")
#

FactoryGirl.define do
  factory :credit do
    amount 250.0
    deposit_type 'paypal_top_up'
  end
end
