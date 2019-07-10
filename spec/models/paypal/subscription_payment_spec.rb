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

require 'rails_helper'

describe Paypal::SubscriptionPayment do
  let(:account) { create :contractor_account }
  let(:contractor) { account.contractor.reload }

  describe 'when processing a payment' do
    it "doesn't add subscription if payment incomplete" do
      expect(contractor.residential_subscribe?).to eq(false)
      create(:paypal_subscription_payment, contractor: contractor, status: 'Failed')
      contractor.reload
      expect(contractor.residential_subscribe?).to eq(false)
    end

    it 'adds subscription for a contractor' do
      subscription_payment = create(:paypal_subscription_payment, contractor: contractor)
      expect { subscription_payment.process }.to change { contractor.subscriptions.count }.by(1)
      contractor.reload
      expect(contractor.commercial_subscribe?).to eq(true)
    end
  end
end
