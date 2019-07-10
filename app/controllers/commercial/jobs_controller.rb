class Commercial::JobsController < CommercialController
  before_action :authenticate_account!, except: [:new, :create]
  before_action :only_client,  only: :new

  before_action :require_country_code, only: [:index, :new, :show, :edit]

  def index
    @account = current_account
    @state = params[:state] || 'all'
    if current_account.homeowner?
      @jobs = Commercial::Job.account_jobs(@state, current_account, params[:page])
      render 'commercial/jobs/index', layout: '../commercial/account/layout'
    elsif current_account.contractor?
      @contractor = current_account.contractor
      if @state == 'purchased'
        @rated_jobs = @contractor.ratings.pluck(:job_id)
        job_ids = @contractor.bids.includes(:job).sort_by(&:created_at).reverse.map(&:job).compact.map(&:id)
      elsif @contractor.is_eligible_to_purchase_leads?
        job_ids = @contractor.commercial_job_leads.map(&:id)
      end
      @jobs = Commercial::Job.includes(:bids).where(id: job_ids)
      @jobs = @jobs.order('approved_at DESC').paginate(page: params[:page], per_page: 50)
      render 'commercial/jobs/index',  layout: '../commercial/contractors/jobs/layout'
    end
  end

  def new
    @job = Commercial::Job.new
    set_global_variables
  end

  def create
    @account = current_account || Account.new(account_params)
    @job = Commercial::Job.new job_params.merge(homeowner: @account)
    set_fee(@job)

    if params[:commercial_job] && params[:commercial_job][:homeowner]
      mobile_number = params[:commercial_job][:homeowner][:mobile_number]
      country = Country.find_by_id(params[:commercial_job][:homeowner][:country_id])
      mobile_number = Textable.normalize(mobile_number, default_phone_code: country.default_phone_code)
      if mobile_number.present?
        @account.mobile_number = mobile_number
      else
        flash.now[:warn] = 'Incorrect mobile number. Please contact us if the problem persists.'
        set_global_variables
        return render 'commercial/jobs/new'
      end
    end

    unless @account.valid?
      flash.now[:warn] = @account.errors.full_messages.to_sentence
      set_global_variables
      return render 'commercial/jobs/new'
    end

    unless @job.valid?
      flash.now[:warn] = @job.errors.full_messages.to_sentence
      set_global_variables
      return render 'commercial/jobs/new'
    end

    @account.save
    @job.save

    images = params[:commercial_job].select{|k,v| k =~ /image[1-5]{0,1}/}.map{|k,v| v}
    images.each do |image|
      @job.photos.create image_name: image
    end

    if current_account
      redirect_to commercial_job_path(locale: current_locale_country, id: @job.id, success: true)
      if @job.save
        @job.thank_homeowner_for_posting_a_job
      end
    else
      flash.now[:notice] = _('Thank you for requesting quotes through Kluje.com')
      render 'home/verify_email'
    end
  end

  def show
    begin
      if current_account.homeowner?
        if current_account.agent?
          @job = Commercial::Job.find(params[:id])
        else
          @job = current_account.jobs.find(params[:id])
        end
        @include_conversion_tag = (params[:success] == 'true')
        render 'commercial/jobs/show', layout: '../commercial/account/layout'
      elsif current_account.contractor?
        @contractor = current_account.contractor
        @job = Commercial::Job.approved.find(params[:id])
        @job.job_views.create(contractor: @contractor) unless @contractor.has_viewed_job?(params[:id])
        @rating = @job.ratings.find_by_contractor_id(@contractor.id)
        @meetings = @job.meetings.where(contractor_id: @contractor.id)
        render 'commercial/jobs/show', layout: '../commercial/contractors/jobs/layout'
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to new_job_path(locale: current_locale_country) if params[:id] == 'create'
      flash[:warn] = 'Job not found'
      redirect_to account_path(locale: current_locale_country)
    end
  end

  def edit
    @job = current_account.jobs.find(params[:id])

    unless @job.approved? || @job.pending?
      flash[:warning] = _('Job is not editable.')
      redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
    end

    set_global_variables

    params[:show] = 'edit'

    render 'commercial/jobs/edit', layout: '../commercial/account/layout'
  end

  def update
    @job = current_account.jobs.find(params[:id])

    unless @job.approved? || @job.pending?
      flash[:warning] = _('Job is not editable.')
      redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
    end

    @new_job = @job.dup
    @new_job.update_attributes(job_params)

    images = params[:commercial_job].select{|k,v| k =~ /image[1-2]{0,1}/}.map{|k,v| v}

    permitted_photos = 2 - @job.photos.count
    images[0...permitted_photos].each do |image|
      @new_job.photos.create image_name: image
    end

    if @new_job.save
      @job.archive
      @job.photos.each do |photo|
        photo.update_attribute(:job_id, @new_job.id)
      end
      @new_job.notify_contractors
      flash[:notice] = _('Job updated successfully')
    else
      flash[:warning] = _('Job cannot be reposted at the moment.')
    end
    redirect_to commercial_job_path(locale: current_locale_country, id: @new_job.id)
  end

  def cancel
    @job = current_account.jobs.find_by_id(params[:job_id])

    unless @job
      flash[:warning] = _('Job ID not found')
      return redirect_to commercial_jobs_path(locale: current_locale_country)
    end

    unless @job.approved? || @job.pending?
      flash[:warning] = _('Job is not editable.')
      return redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
    end

    if @job.archive
      flash[:notice] = _('Job is successfully archived.')
    else
      flash[:warning] = _('Job cannot be cancelled at the moment.')
    end

    redirect_to commercial_jobs_path(locale: current_locale_country)
  end

  def bid
    contractor = current_account.contractor
    unless contractor.commercial_subscribe?
      flash[:notice] = _('Please subscribe before you bid a job')
      return redirect_to commercial_subscriptions_path(locale: current_locale_country)
    end

    job = Commercial::Job.approved.find(params[:job_id])
    if job.can_accept_bid? && contractor.can_bid_for_commercial_job?(job)
      job.accept_bid(contractor)
      flash[:notice] = _('Job lead bided!')
      return redirect_to commercial_job_path(locale: current_locale_country, id: params[:job_id])
    end

    if !contractor.account.email_verified?
      flash[:error] = _("Please verify your email before bidding")
    elsif contractor.account.suspended?
      flash[:error] = _("Your account has been suspended")
    elsif contractor.has_bidded_for_job?(job)
      flash[:error] = _("You have already bidded for this job")
    end
    redirect_to commercial_jobs_path(locale: current_locale_country)
  end

  def quoter_form
    @job = Commercial::Job.approved.find(params[:job_id])
    bid = Bid.find(params[:id])
    if current_account.contractor?
      if params[:bid][:amount_quoter].blank?
        flash[:error] = _("Please enter a Quote amount")
      else
        if bid.update_attributes(bid_params)
          if current_account.contractor?
            @job.notify_homeowner_commercial_job_quoted bid.contractor
            flash[:notice] = _("Quote was uploaded")
          elsif current_account.homeowner?
            @job.notify_contractor_commercial_job_quote_accepted bid.contractor
            flash[:notice] = _("Quote was accepted")
          end
        else
          flash[:error] = _("Quote was not uploaded")
        end
      end
    elsif current_account.homeowner?
      if bid.update_attributes(bid_params)
        @job.notify_contractor_commercial_job_quote_accepted bid.contractor
        flash[:notice] = _("Quote was accepted")
      else
        flash[:error] = _("Quote was not updated")
      end

    end
    redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
  end

  private

  def account_params
    params.require(:commercial_job).require(:homeowner).permit(:first_name, :last_name,
                                                               :email, :password,
                                                               :mobile_number, :country_id)
  end

  def job_params
    params.require(:commercial_job).permit(:homeowner, :city_id, :skill_id,
                                           :job_category_id, :description,
                                           :availability_id, :budget_value,
                                           :postal_code, :contact_time_id,
                                           :property_type, :floor_size,
                                           :renovation_type, :address,
                                           :concierge_service, :start_date, :concierges_service_amount, :number_of_quote,
                                           :client_first_name, :client_last_name, :client_email, :client_mobile_number, :partner_code)
  end

  def bid_params
    params.require(:bid).permit(:amount_quoter, :accept, :file)
  end

  def clarification_params
    params.require(:clarification).permit(:question, :answer)
  end

  def only_client
    if current_account.present? && current_account.contractor?
      redirect_to jobs_path(locale: current_locale_country), alert: 'Only client can post a job'
    end
  end

  def set_fee(job)
    fee = Fee.find_or_create_by(country_id: job.country.id)
    job.commission_rate = fee.commission
    job.concierges_service_amount = fee.concierge if job.concierge_service
  end

  def set_global_variables
    @availabilities = Commercial::Job.availabilities.to_a.map{ |i| [i[1], i[0].to_s] }
    @contact_times = Commercial::Job.contact_times.to_a.map{ |i| [i[1], i[0].to_s] }
    @property_types = Commercial::Job.property_types.to_a.map{ |i| [i[1], i[0].to_s] }
    @renovation_types = Commercial::Job.renovation_types.to_a.map{ |i| [i[1], i[0].to_s] }
    @floor_sizes = Commercial::Job.floor_sizes.to_a.map{ |i| [i[1], i[0].to_s] }

    @city = City.find(params[:city_id]) if params[:city_id]
    @country = @city.try(:country) || (params[:country_id] && Country.find(params[:country_id])) || current_country

    params[:specific_contractor_id] ||= params[:contractor_id]
    if params[:specific_contractor_id].present?
      @contractor = Contractor.find_by_id(params[:specific_contractor_id])
      @skills = Contractor.find(params[:specific_contractor_id]).skills
      @job.specific_contractor_id ||= params[:specific_contractor_id]
    else
      @skills = Skill.all
    end
    @job.skill_id ||= params[:skill_id]
  end
end
