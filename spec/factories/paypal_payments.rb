# == Schema Information
#
# Table name: paypal_payments
#
#  id                        :integer          not null, primary key
#  contractor_id             :integer
#  membership_id             :integer
#  txn_id                    :string(255)
#  txn_type                  :string(255)
#  amount                    :decimal(13, 2)
#  fee                       :decimal(12, 2)
#  currency                  :string(255)
#  status                    :string(255)
#  type                      :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  params                    :text(65535)
#  braintree_subscription_id :string(255)
#  payment_type              :integer          not null
#

# rubocop:disable Lint/ParenthesesAsGroupedExpression
FactoryGirl.define do
  sequence(:txn_id) { |n| "transaction#{n}" }

  factory :paypal_payment, class: Paypal::Payment do
    txn_id
    amount 100.00
    currency 'SGD'
    fee 4.00
    status 'Completed'
    params ({
      txn_type: 'card', mc_fee: '4.40', mc_currency: 'SGD',
      test_ipn: '1', business: Settings['paypal']['business_id'], custom: ''
    })
    payment_type 0
  end

  factory :paypal_top_up, class: Paypal::TopUp do
    txn_id
    amount 100.00
    currency 'SGD'
    fee 4.00
    status 'Completed'
    params ({
      txn_type: 'card', mc_fee: '4.40', mc_currency: 'SGD',
      test_ipn: '1', business: Settings['paypal']['business_id'], custom: 'TopUp,1,50.00'
    })
    payment_type 0
  end

  factory :paypal_subscription_payment, class: Paypal::SubscriptionPayment do
    txn_id
    amount 100.00
    currency 'SGD'
    status 'Completed'
    params ({
      txn_type: 'card', mc_fee: '4.40', mc_currency: 'SGD',
      test_ipn: '1', business: Settings['paypal']['business_id'], custom: 'Subscription'
    })
    payment_type 0
  end
end
