class Commercial::SubscriptionsController < ApplicationController
  before_action :set_contractor
  before_action :require_country_code, only: [:index, :invoices, :show_invoice]

  def index
    fields = payment_field.merge({
      p3: 1,
      t3: 'M',
      src: 1,
      modify: 0,
      cmd: '_s-xclick',
      return: commercial_subscriptions_url(locale: current_locale_country, action: 'success'),
      cancel_return: commercial_subscriptions_url(locale: current_locale_country, action: 'cancelled'),
      hosted_button_id: Settings['paypal']['commercial_subscription_id'][current_country.cca2],
    })
    action = request.env["action_dispatch.request.query_parameters"][:action]
    if action == 'success'
      flash.now[:notice] = "Thank you for your subscription!"
    end
    render 'commercial/subscriptions/index', locals: { fields: fields }
  end

  def invoices
    Subscription.reload(@contractor)
    @subscriptions = @contractor.subscriptions.order(expired_at: :desc).paginate(page: params[:page], per_page: 10)
  end

  def show_invoice
    @subscription = Subscription.find_by(id: params[:id])

    respond_to do |format|
      format.pdf do
        pdf = SubscriptionInvoicePDF.new(@subscription, current_account)
        send_data pdf.render,
          filename:    "#{@subscription.id}.pdf",
          type:        "application/pdf",
          disposition: "inline"
      end
    end
  end

  def unsubscribe
    if expiry_date = @contractor.unsubscribe
      flash.now[:notice] = "Unsubscribe successful.You can enjoy subscription until #{expiry_date}"
    else
      flash.now[:notice] = "Error has occurred. Please unsubscribe again"
    end
    @subscriptions = @contractor.subscriptions.order(expired_at: :desc).paginate(page: params[:page], per_page: 10)
    render 'commercial/subscriptions/invoices'
  end

  def waiting_list
    if WaitingList.create(contractor: @contractor)
      flash[:notice] = "Thank you for your request"
    else
      flash[:notice] = "Error has occurred. Please click the button again"
    end
    redirect_to commercial_jobs_path(locale: current_locale_country)
  end

  private

  def set_contractor
    return if current_account.homeowner?
    @contractor = current_account.contractor
  end

  def payment_field
    {
      business: Settings['paypal']['business_email'],
      no_shipping: 1,
      no_note: 1,
      tax: 0,
      rm: 1,
      cpp_cart_border_color: 'f8a92d',
      cpp_logo_image: ActionController::Base.helpers.image_url('kluje_paypal.png'),
      notify_url: notify_payments_url,
    }
  end
end
