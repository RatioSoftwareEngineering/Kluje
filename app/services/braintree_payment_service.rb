class BraintreePaymentService

  attr_reader :result

  def initialize(params)
    @params = params
    @nonce = params[:payment_method_nonce]
    @amount = params[:amount]
    @currency = params[:currency_code]
  end

  def top_up(account)
    @result = braintree_transaction

    if @result.success?

    elsif @result.transaction
      Rails.logger.error 'Error processing top up transaction:'
      Rails.logger.error "  code: #{result.transaction.processor_response_code}"
      Rails.logger.error "  text: #{result.transaction.processor_response_text}"
    else
      Rails.logger.error 'Error processing top up:'
      Rails.logger.error result.params.inspect
      Rails.logger.error result.errors.inspect
    end
    @payment = Paypal::TopUp.new(contractor_id: account.contractor_id, payment_type: :braintree)
    payment_process
  end

  def subscribe(account)
    @result = braintree_subscription(account)
    if @result.success?

    elsif @result.transaction
      Rails.logger.error 'Error processing subscribe transaction:'
      Rails.logger.error "  code: #{result.transaction.processor_response_code}"
      Rails.logger.error "  text: #{result.transaction.processor_response_text}"
    else
      Rails.logger.error 'Error processing subscribe:'
      Rails.logger.error result.params.inspect
      Rails.logger.error result.errors.inspect
    end
    @payment = Paypal::SubscriptionPayment.new(contractor_id: account.contractor_id, payment_type: :braintree)
    payment_process
  end

  private

  def braintree_transaction
    Braintree::Transaction.sale(
        :amount => @amount,
        :merchant_account_id => "kluje#{@currency}",
        :payment_method_nonce => @nonce,
        options: {
            submit_for_settlement: true
        }
    )
  end

  def braintree_subscription(account)
    result = Braintree::Customer.create(
        first_name: account.first_name,
        last_name: account.last_name,
        email: account.email,
        company: account.contractor.company_name,
        payment_method_nonce: @nonce
    )
    Braintree::Subscription.create(
        plan_id: 'c9yb',
        merchant_account_id: "kluje#{@currency}",
        payment_method_token: result.customer.payment_methods[0].token,
        price: @amount
    )
  end

  def payment_process
    set_payment
    @payment.save
    @payment.process
  end

  def set_payment
    if @result.success?
      set_successful_payment
    else
      set_error_payment
    end
  end

  def set_successful_payment
    transaction = @result.try(:transaction)
    unless transaction
      transaction = @result.subscription.transactions[0]
      @payment.braintree_subscription_id = @result.subscription.id
    end

    @payment.txn_id = transaction.id
    @payment.txn_type = "braintree_#{transaction.type}"
    @payment.amount = transaction.amount
    @payment.fee = transaction.service_fee_amount || '0.00'
    @payment.currency = transaction.currency_iso_code
    @payment.status = transaction.status

    @payment.params ||= {}
    @payment.params = @payment.params.merge(@params).with_indifferent_access
    transaction_params = {}
    [:id, :type, :amount, :status, :created_at, :credit_card_details,
     :customer_details, :subscription_details, :updated_at,
     :merchant_account_id].each do |field|
      transaction_params[field] = transaction.send(field).as_json
    end
    @payment.params = @payment.params.merge(braintree: transaction_params).with_indifferent_access
  end

  def set_error_payment
    @payment.params ||= {}
    @payment.amount = @amount
    @payment.currency = @currency
    result_params = {errors: @result.errors, params: @result.params}.as_json
    @payment.params = @payment.params.merge(braintree: result_params).with_indifferent_access
  end

end
