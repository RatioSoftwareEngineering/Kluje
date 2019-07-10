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

module Paypal
  class SubscriptionPayment < Payment
    has_one :subscription

    def do_process
      # expired_at = contractor.residential_subscription_expiry_date
      expired_at = (Time.zone.now - 1.day) unless expired_at
      Subscription.create(
        contractor_id: contractor.id,
        expired_at: expired_at + 1.month,
        currency: currency,
        price: amount,
        category: :commercial,
        auto_reload: true,
        subscription_payment_id: id
      )
    end
  end
end
