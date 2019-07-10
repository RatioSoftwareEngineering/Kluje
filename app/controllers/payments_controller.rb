require 'open-uri'

class PaymentsController < ApplicationController
  protect_from_forgery only: [:notify], with: :null_session

  def client_key
    Braintree::ClientToken.generate
  end

  def top_up
    payment_service = BraintreePaymentService.new(params)
    payment_service.top_up(current_account)
    if payment_service.result.success?
      flash[:info] = _('Successfully topped up %s') % "#{params[:amount]} #{params[:currency_code]}"
    else
      flash[:info] = _('Error processing transaction')
    end
    redirect_to billing_top_up_contractors_path(locale: current_locale_country)
  end

  def subscribe
    payment_service = BraintreePaymentService.new(params)
    payment_service.subscribe(current_account)
    if payment_service.result.success?
      flash[:info] = _('Successfully subscribed') % "#{params[:amount]} #{params[:currency_code]}"
    else
      flash[:info] = _('Error processing Subscription')
    end
    if params[:item_name] == 'CommercialSubscription'
      redirect_to commercial_subscriptions_path(locale: current_locale_country)
    else
      redirect_to billing_subscription_contractors_path
    end
  end

  def notify
    payment_service = PaypalPaymentService.new(params)
    response = open(paypay_submit_url).read
    payment_service.run(logger, response)
    render nothing: true
  end

  private

  def paypay_submit_url
    "#{Settings['paypal']['submit_url']}?cmd=_notify-validate&#{request.env['rack.input'].read}"
  end
end
