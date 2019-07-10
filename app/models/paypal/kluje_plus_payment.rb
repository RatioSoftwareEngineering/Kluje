module Paypal
  class KlujePlusPayment < ActiveRecord::Base
    belongs_to :job_x
    belongs_to :homeowner
    serialize :params

    def process
      if ready_to_process?
        update_attributes(status: 'Processed') if do_process
      else
        logger.warn "Failed to process #{type} payment #{id}"
      end
    end

    def ready_to_process?
      correctly_addressed? && amount_correct? && completed? && !processed?
    end

    def processed?
      KlujePlusPayment.where("txn_id = '#{txn_id}' AND status = 'Processed'").present?
    end

    def completed?
      status == 'Completed'
    end

    def pending?
      status == 'Pending'
    end

    def correctly_addressed?
      [Settings['paypal']['business_id'], Settings['paypal']['business_email']].include? business
    end

    def amount_correct?
      currency == 'SGD' && amount > 0
    end

    def test?
      params[:test_ipn] == '1'
    end

    def business
      params[:business] || params[:receiver_email]
    end
  end
end
