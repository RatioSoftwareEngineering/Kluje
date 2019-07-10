class PaypalPaymentService

  def initialize(params)
    @params = params
    @transaction_type, @contractor_id, @type = params[:custom].split(',') if params[:custom]
    @txn_id = params[:txn_id] || params[:subscr_id] || ''
  end

  def run(logger, response)
    if response == 'VERIFIED'
      payment_process(logger)
    else
      logger.warn "Invalid PayPal IPN: #{params}"
    end
  end

  private

  def payment_process(logger)
    logger.info "PayPal IPN verified: #{@params.inspect}"
    if Paypal::Payment.txn_processed?(@txn_id)
      logger.info "Paypal IPN Processed: #{@txn_id}"
      return
    end

    if @transaction_type == 'TopUp'
      @payment = Paypal::TopUp.create(contractor_id: @contractor_id.to_i, payment_type: :paypal)
    elsif @transaction_type == 'Subscription'
      @payment = Paypal::SubscriptionPayment.create(contractor_id: @contractor_id.to_i, payment_type: :paypal)
    else
      logger.warn "Unrecognized transaction"
    end

    set_payment if @payment.present?
  end

  def set_payment
    @payment.txn_id = @txn_id
    @payment.txn_type = @params[:txn_type]
    @payment.amount = @params[:mc_gross] || '0.00'
    @payment.fee = @params[:mc_fee] || '0.00'
    @payment.currency = @params[:mc_currency]
    @payment.status = @params[:payment_status]
    @payment.params ||= {}
    @payment.params = @payment.params.merge(@params).with_indifferent_access
    @payment.save
    @payment.process
  end

end
