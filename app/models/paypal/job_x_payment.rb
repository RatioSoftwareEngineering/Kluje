module Paypal
  class JobXPayment < KlujePlusPayment
    def do_process
      if job_x.nil?
        logger.warn "Failed to process #{job_x} payment"
      else
        @job_x_payment = JobXPayment.new(job_x: job_x, amount: amount)
        @job_x_payment.save
      end
    end
  end
end
