module Paypal
  class BoostedPayment < KlujePlusPayment
    def do_process
      if homeowner.nil?
        logger.warn "Failed to process #{homeowner} payment"
      else
        @boosted_payment = BoostedPayment.new(homeowner: homeowner, amount: amount)
        @boosted_payment.save
      end
    end
  end
end
