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

class Subscription < ActiveRecord::Base
  validates :contractor_id, presence: true
  validates :expired_at, presence: true

  belongs_to :contractor
  belongs_to :subscription_payment, class_name: 'Paypal::SubscriptionPayment'

  enum category: { residential: 0, commercial: 1 }

  # rubocop:disable Metrics/CyclomaticComplexity
  def self.reload(contractor)
    expired_at = contractor.commercial_subscription_expiry_date
    return if expired_at.nil? || expired_at > Time.zone.now || !payment_active?(contractor)

    while expired_at && expired_at < Time.zone.now
      s = contractor.subscriptions.residential.last
      return false if s.nil?

      return s.auto_reload
      # create(
      #   contractor_id: contractor.id, expired_at: expired_at + 1.month,
      #   currency: s.currency, price: s.price, category: :residential, auto_reload: true
      # )
      # expired_at = contractor.residential_subscription_expiry_date
    end
  end

  def self.payment_active?(contractor)
    payment = contractor.subscription_payments.last
    return false unless payment

    if payment.braintree?
      begin
        Braintree::Subscription.find(payment.braintree_subscription_id).status == 'Active'
      rescue
        return false
      end
    else
      payment.txn_type != 'subscr_cancel'
    end
  end
end
