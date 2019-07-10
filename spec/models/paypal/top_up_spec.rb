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

describe Paypal::TopUp do
  let(:account) { create :contractor_account }
  let(:contractor) { account.contractor.reload }

  describe 'when saving a top_up' do
    it 'creates a top_up' do
      top_up = build(:paypal_top_up, contractor: contractor)
      expect(top_up.save).to be true
    end
  end

  describe 'when processing a payment' do
    it 'fails if no account' do
      top_up = create(:paypal_top_up)
      top_up.process
      expect(top_up.status).to eq('Completed')
    end

    it 'succeeds if a contractor' do
      top_up = create(:paypal_top_up, contractor: contractor)
      expect(top_up.process).to be true
    end

    it 'adds credit for a contractor' do
      num_credits = contractor.credits.length
      top_up = create(:paypal_top_up, contractor: contractor)
      top_up.process

      contractor.reload
      credit = Credit.last
      expect(credit.contractor_id).to eq contractor.id
      expect(contractor.credits.length).to eq num_credits + 1
      expect(credit.amount).to eq top_up.amount
      expect(credit.amount).to eq BigDecimal.new('100.00')
    end

    it 'adds correct amount of credit' do
      expect(contractor.credits_balance).to eq 250.0
      top_up = create(:paypal_top_up, contractor: contractor, amount: '29.37')
      top_up.process
      credit = Credit.last
      expect(credit.contractor_id).to eq contractor.id
      expect(credit.amount).to eq top_up.amount
      expect(credit.amount).to eq BigDecimal.new('29.37')
      expect(contractor.credits_balance).to eq 279.37
    end

    it 'doesnt add credit if payment incomplete' do
      expect(contractor.credits_balance).to eq 250.0
      create(:paypal_top_up, contractor: contractor, status: 'Failed')
      contractor.reload
      expect(contractor.credits_balance).to eq 250.0
    end

    it 'doesnt add credit twice' do
      credit = Credit.where(contractor_id: contractor.id).sum(:amount)
      expect(credit).to eq(BigDecimal.new('250.00'))

      [create(:paypal_top_up, contractor: contractor, txn_id: 't1', amount: '10.00'),
       create(:paypal_top_up, contractor: contractor, txn_id: 't1', amount: '10.00'),
       create(:paypal_top_up, contractor: contractor, txn_id: 't1', amount: '10.00'),
       create(:paypal_top_up, contractor: contractor, txn_id: 't2', amount: '10.00'),
       create(:paypal_top_up, contractor: contractor, txn_id: 't3', amount: '7.00')].each(&:process)

      credit = Credit.where(contractor_id: contractor.id).sum(:amount)
      expect(credit).to eq(BigDecimal.new('277.00'))
    end
  end
end
