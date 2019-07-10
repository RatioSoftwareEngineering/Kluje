# rubocop:disable Metrics/ClassLength
class JobsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:categories, :skills]

  before_action :ensure_signed_in, only: [:edit, :update, :cancel, :index,
                                          :show, :bid]
  before_action :ensure_homeowner_or_anonymous, only: [:new, :create]
  before_action :ensure_homeowner, only: [:edit, :update, :cancel]
  before_action :ensure_contractor, only: [:bid]
  before_action :authenticate_account!, except: [:new, :create, :categories, :skills, :budgets]

  before_action :require_country_code, only: [:index, :new, :show, :edit]

  def new
    # return redirect_to new_commercial_job_path(locale: current_locale_country) if current_account && current_account.commercial?
    @job = Residential::Job.new(homeowner: current_account || Account.new)
    set_global_variables
    render 'jobs/new'
  end

  def create # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    @account = current_account || Account.new(account_params)
    @job = Residential::Job.new job_params.merge(homeowner: @account)

    if params[:residential_job] && params[:residential_job][:homeowner_attributes]
      mobile_number = params[:residential_job][:homeowner_attributes][:mobile_number]
      country = Country.find_by_id(params[:residential_job][:homeowner_attributes][:country_id])
      mobile_number = Textable.normalize(mobile_number, default_phone_code: country.default_phone_code)
      if mobile_number.present?
        @account.mobile_number = mobile_number
      else
        flash.now[:warn] = 'Incorrect mobile number. Please contact us if the problem persists.'
        set_global_variables
        return render 'jobs/new'
      end
    end

    unless @account.valid?
      flash.now[:warn] = @account.errors.full_messages.to_sentence
      set_global_variables
      return render 'jobs/new'
    end

    if @account.mobile_number.nil?
      flash.now[:warn] = 'Invalid mobile number'
      set_global_variables
      return render 'jobs/new'
    end

    unless @job.valid?
      flash.now[:warn] = @job.errors.full_messages.to_sentence
      set_global_variables
      return render 'jobs/new'
    end

    @account.save
    @job.save

    images = params[:residential_job].select { |k, _v| k =~ /image[1-5]{0,1}/ }.map { |_k, v| v }
    images.each do |image|
      @job.photos.create image_name: image
    end

    if current_account
      redirect_to job_path(locale: current_locale_country, id: @job.id, success: true)
    else
      flash.now[:notice] = _('Thank you for requesting quotes through Kluje.com')
      render 'home/verify_email'
    end
  end

  def index # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # return redirect_to commercial_jobs_path(locale: current_locale_country) if current_account.contractor? && current_account.commercial?
    @account = current_account

    @state = params[:state] || 'all'
    if current_account.homeowner?
      @jobs = Residential::Job.includes(:bids, :job_category, :skill, :city)
              .where(@state == 'all' ? "state != 'archived'" : "state = '#{@state}'")
              .where(homeowner_id: current_account.id)
              .order('created_at DESC')
              .paginate(page: params[:page], per_page: 10)
      render 'jobs/index', layout: '../homeowners/account/layout'
    elsif current_account.contractor?
      @contractor = current_account.contractor
      if @state == 'purchased'
        @rated_jobs = @contractor.ratings.pluck(:job_id)
        job_ids = @contractor.bids.includes(:job).sort_by(&:created_at).reverse.map(&:job).compact.map(&:id)
      elsif @contractor.is_eligible_to_purchase_leads?
        job_ids = @contractor.cache_job_leads
      end
      @jobs = Residential::Job.includes(:bids, :job_category, :city).where(id: job_ids)\
              .order('approved_at DESC').paginate(page: params[:page], per_page: 50)
      render 'jobs/index', layout: '../contractors/jobs/layout'
    end
  end

  def show
    if current_account.homeowner?
      @job = current_account.jobs.find(params[:id])
      @include_conversion_tag = (params[:success] == 'true')
      render 'jobs/show', layout: '../homeowners/account/layout'
    elsif current_account.contractor?
      @contractor = current_account.contractor
      @job = Residential::Job.approved.find(params[:id])
      @job.job_views.create(contractor: @contractor) unless @contractor.has_viewed_job?(params[:id])
      @rating = @job.ratings.find_by_contractor_id(@contractor.id)
      render 'jobs/show', layout: '../contractors/jobs/layout'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_job_path(locale: current_locale_country) if params[:id] == 'create'
    flash[:warn] = 'Job not found'
    redirect_to account_path(locale: current_locale_country)
  end

  def edit
    @job = current_account.jobs.find(params[:id])

    unless @job.approved? || @job.pending?
      flash[:warning] = _('Job is not editable.')
      redirect_to job_path(locale: current_locale_country, id: @job.id)
    end

    set_global_variables

    params[:show] = 'edit'

    render 'jobs/edit', layout: '../homeowners/account/layout'
  end

  def update # rubocop:disable Metrics/AbcSize
    @job = current_account.jobs.find(params[:id])

    unless @job.approved? || @job.pending?
      flash[:warning] = _('Job is not editable.')
      return redirect_to job_path(locale: current_locale_country, id: @job.id)
    end

    @new_job = @job.dup
    @new_job.update_attributes(job_params)
    @new_job.update_attributes(approved_at: Time.zone.now)

    images = params[:residential_job].select { |k, _v| k =~ /image[1-5]{0,1}/ }.map { |_k, v| v }

    permitted_photos = 5 - @job.photos.count
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
      redirect_to job_path(locale: current_locale_country, id: @new_job.id)
    else
      flash[:warning] = _('Job cannot be reposted at the moment.')
      redirect_to job_path(locale: current_locale_country, id: @job.id)
    end
  end

  def cancel
    @job = current_account.jobs.find_by_id(params[:job_id])

    unless @job
      flash[:warning] = _('Job ID not found')
      return redirect_to jobs_path(locale: current_locale_country)
    end

    if @job.archive
      flash[:notice] = _('Job is successfully archived.')
    else
      flash[:warning] = _('Job cannot be cancelled at the moment.')
    end

    redirect_to jobs_path(locale: current_locale_country)
  end

  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def bid
    job = Residential::Job.approved.find(params[:job_id])
    contractor = current_account.contractor
    if job.can_accept_bid? && contractor.can_bid_for_job?(job)
      job.accept_bid(contractor)
      flash[:notice] = _('Job lead purchased!')
      return redirect_to job_path(locale: current_locale_country, id: params[:job_id])
    elsif !contractor.account.email_verified?
      flash[:error] = _('Please verify your email before bidding')
    elsif contractor.account.suspended?
      flash[:error] = _('Your account has been suspended')
    elsif contractor.has_bidded_for_job?(job)
      flash[:error] = _('You have already bidded for this job')
    elsif contractor.credits_balance < job.lead_price
      flash[:error] = _("You don't have enough credits to purchase this lead")
    end
    redirect_to jobs_path(locale: current_locale_country)
  end

  def categories
    categories = JobCategory.where(skill_id: params[:skill_id]).order(:name)
    render json: categories.as_json(only: [:id, :translated_name])
  end

  def skills
    @skills_table = Rails.cache.fetch("skills_and_job_categories_#{params[:lang] || current_locale}", expires_in: 24.hours) do
      Skill.skills_table
    end
    render '/home/skills_table.js', layout: nil
  end

  def budgets
    return [] unless params[:job_category_id].present?
    job_category = JobCategory.find_by_id(params[:job_category_id])
    country = Country.find_by_id(params[:country_id]) || current_country
    budgets =  job_category.budgets.map do |budget|
      country_budget = country.budgets.find_by_budget_id(budget.id)
      {
        id: budget.id,
        start_price: country_budget.try(:start_price),
        end_price: country_budget.try(:end_price),
        lead_price: country_budget.try(:lead_price),
        currency: country.currency_code,
        range: country_budget.try(:range)
      }
    end
    render json: { budgets: budgets }
  end

  private

  def account_params
    params.require(:residential_job).require(:homeowner).permit(:first_name, :last_name,
                                                                :email, :password,
                                                                :mobile_number, :country_id)
  end

  def ensure_contractor
    if current_account.contractor?
      if !current_account.mobile_number
        redirect_to message_confirmation_contractors_path
      elsif !current_account.country
        flash[:warning] = _('Please update your country')
        redirect_to account_details_contractors_path(locale: current_locale_country)
      end
    else
      flash[:notice] = _('%{role} are not allowed to perform this action') % {
        role: current_account.role.humanize.pluralize
      }
      redirect_to jobs_path(locale: current_locale_country)
    end
  end

  def ensure_homeowner
    if signed_in? && current_account.homeowner?
      if current_account.country.blank? || current_account.mobile_number.blank?
        flash[:notice] = _('Update your location and contact details')
        redirect_to account_path(locale: current_locale_country)
      end
    else
      flash[:notice] = _('%{role} are not allowed to perform this action') % {
        role: current_account.role.humanize.pluralize
      }
      redirect_to jobs_path(locale: current_locale_country)
    end
  end

  def ensure_homeowner_or_anonymous
    return unless signed_in? && !current_account.homeowner?

    flash[:notice] = _('%{role} are not allowed to perform this action') % {
      role: current_account.role.humanize.pluralize
    }
    redirect_to jobs_path(locale: current_locale_country)
  end

  def job_params
    params.require(:residential_job).permit('homeowner', 'city_id', 'skill_id', 'job_category_id', 'description',
                                            'availability_id', 'budget_id', 'postal_code',
                                            'contact_time_id', 'property_type')
  end

  # rubocop:disable Metrics/AbcSize
  def set_global_variables
    @availabilities = Residential::Job.availabilities.to_a.map { |i| [i[1], i[0].to_s] }
    @contact_times = Residential::Job.contact_times.to_a.map { |i| [i[1], i[0].to_s] }
    @property_types = Residential::Job.property_types.to_a.map { |i| [i[1], i[0].to_s] }

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
