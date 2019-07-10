class Commercial::InvoicesController < ApplicationController

  layout "commercial"

  before_action :invoices_search, only: :index
  before_action :set_contractor, only: [:index, :create]
  before_action :find_job, except: [:show, :index]
  before_action :ensure_correct_homeowner, only: [:edit, :update]
  before_action :ensure_correct_contractor, only: [:new, :create]

  before_action :require_country_code, only: [:index]

  def index
    if current_account.homeowner?
      @jobs = Commercial::Job.where(homeowner_id: current_account.id)
    elsif current_account.contractor?
      @rated_jobs = @contractor.ratings.pluck(:job_id)
      set_jobs
    end
    @invoices = @invoices.order('created_at DESC').paginate(page: params[:page], per_page: 10)
  end

  def new
    @invoice = Invoice.new()
  end

  def create
    @client = @job.homeowner
    @invoice = Invoice.new(invoice_params)
    if @invoice.save
      @job.invoice = @invoice
      flash[:success] = 'Your invoice has been sent to the Client.'
      CommercialMailer.notify_client_invoice(@client, @contractor, @invoice).deliver
      CommercialMailer.notify_contractor_commission_invoice(@contractor, @job, pdf_url).deliver
    else
      flash[:error] = 'Unable to submit your invoice. Please try again.'
    end
    redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
  end

  def show
    @invoice = Invoice.find(params[:id])

    respond_to do |format|
      format.pdf do
        pdf = InvoicePDF.new(@invoice, current_account)
        send_data pdf.render,
          filename:    "#{@invoice.id}.pdf",
          type:        "application/pdf",
          disposition: "inline"
      end
    end
  end

  def update
    @invoice = Invoice.find(params[:id])
    if @invoice.update_attributes(invoice_params)
      flash[:success] = 'Paided.'
    else
      flash[:error] = 'Not paided.'
    end
    redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
  end

  private

  def invoices_search
    @invoices = Invoice.account_search(current_account)
  end

  def set_contractor
    return if current_account.homeowner?
    @contractor = current_account.contractor
  end

  def set_jobs
    job_ids = @contractor.bids.includes(:job).sort_by(&:created_at).reverse.map(&:job).compact.map(&:id)
    @jobs = Commercial::Job.where(id: job_ids)
    @jobs = @jobs.order('approved_at DESC').paginate(page: params[:page], per_page: 50)
  end

  def find_job
    @job = Commercial::Job.find(params[:invoice][:job_id])
  end

  def ensure_correct_contractor
    unless current_account.contractor? &&
        @job.bids.find_by(contractor_id: current_account.contractor.id).present?
      flash[:warning] = _("You have no permission to access this site.")
      redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
    end
  end

  def ensure_correct_homeowner
    unless @job && @job.homeowner_id == current_account.id
      flash[:warning] = _("You have no permission to access this site.")
      redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
    end
  end

  def invoice_params
    params.require(:invoice).permit(:amount, :file, :currency, :paid).merge(job_id: @job.id, sender_id: @contractor.id, sender_type: 'Contractor', recipient_id: @job.homeowner_id, recipient_type: 'Account', currency: @job.country.currency_code, commission: @job.commission_rate, concierge: @job.concierges_service_amount)
  end

  def pdf_url
    request.url + '/' + @invoice.id.to_s + '.pdf'
  end
end
