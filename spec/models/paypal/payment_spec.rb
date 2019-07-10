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

describe Paypal::Payment do
  let(:account) { create :contractor_account }
  let(:contractor) { account.contractor.reload }
  let(:params) do
    { txn_type: 'card', mc_fee: '4.40', mc_currency: 'SGD', test_ipn: '1',
      business: Settings['paypal']['business_email'] }
  end

  describe 'when saving a payment' do
    it 'creates a payment' do
      payment = build(:paypal_payment, contractor: contractor)
      expect(payment.save).to be true
    end

    it 'creates a payment even if data incomplete' do
      payment = Paypal::Payment.create(txn_id: 1, amount: 2.00, payment_type: 0)
      expect(payment.save).to be true
    end
  end

  describe 'when processing a payment' do
    it 'doesnt process if addressed incorrectly' do
      params[:business] = 'incorrect@email.com'
      payment = create(:paypal_payment, contractor: contractor, params: params)
      expect(payment.business).to eq('incorrect@email.com')
      expect(payment.correctly_addressed?).to be false
      expect(payment.amount_correct?).to be true
      expect(payment.completed?).to be true
      expect(payment.ready_to_process?).to be false
    end

    it 'doesnt process if incorrect currency' do
      payment = create(:paypal_payment, contractor: contractor, currency: 'PLN', params: params)
      expect(payment.currency).to eq('PLN')

      expect(payment.correctly_addressed?).to be true
      expect(payment.amount_correct?).to be false
      expect(payment.completed?).to be true
      expect(payment.ready_to_process?).to be false
    end

    it 'doesnt process if payment not complete' do
      payment = create(:paypal_payment, amount: 1.00, currency: 'SGD', contractor: contractor, status: 'Incomplete')

      expect(payment.correctly_addressed?).to be true
      expect(payment.amount_correct?).to be true
      expect(payment.completed?).to be false
      expect(payment.ready_to_process?).to be false
    end
  end
end
