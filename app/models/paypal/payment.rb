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
  class Payment < ActiveRecord::Base
    self.table_name = 'paypal_payments'
    belongs_to :contractor

    before_save :ensure_params

    serialize :params

    scope :processed, -> { where(status: 'Processed') }
    scope :latest, -> { order('created_at DESC').limit(1) }

    enum payment_type: { braintree: 0, paypal: 1 }

    def process
      if ready_to_process? && contractor.present?
        update_attributes(status: 'Processed') if do_process
      else
        logger.warn "Failed to process #{type} payment #{id} for #{contractor} txn #{txn_id}"
      end
    end

    def ready_to_process?
      correctly_addressed? && amount_correct? && completed? && !processed?
    end

    def processed?
      Payment.where("txn_id = '#{txn_id}' AND status = 'Processed'").present?
    end

    def self.txn_processed?(id)
      Payment.where("txn_id = ? AND status = 'Processed'", id).present?
    end

    def completed?
      status == 'Completed' || status == 'submitted_for_settlement' || status == 'settling' || status == 'settled'
    end

    def pending?
      status == 'Pending'
    end

    def correctly_addressed?
      if params[:braintree].present?
        merchant_account_id = params[:braintree][:merchant_account_id]
        merchant_account_id ||= params[:braintree][:params][:transaction][:merchant_account_id]
        return merchant_account_id =~ /^kluje/ ? true : false
      end
      [Settings['paypal']['business_id'], Settings['paypal']['business_email']].include? business
    end

    def amount_correct?
      expected_currency = contractor.try(:account).try(:country).try(:currency_code).try(:downcase)
      currency.downcase == expected_currency &&
        amount > 0
    end

    def test?
      params[:test_ipn] == '1'
    end

    def business
      params[:business] || params[:receiver_email]
    end

    private

    def ensure_params
      self.params ||= {}
    end
  end
end
