class Commercial::RatingsController < CommercialController

  before_action :find_contactor, only: [:new, :create]
  before_action :find_job
  before_action :ensure_signed_in
  before_action :ensure_correct_homeowner, only: [:new, :create]
  before_action :ensure_correct_contractor, only: [:request_a_rating]
  before_action :require_country_code, only: [:new]

  def new
    if @job.is_eligible_for_review?(@contractor.id)
      render 'commercial/ratings/new'
    else
      flash[:error] = _("You've already rated the contractor previously!")
      redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
    end
  end

  def create
    if @job.is_eligible_for_review?(@contractor.id)
      @rating = @job.ratings.new( rating_params.merge(contractor_id: @contractor.id) )
    end

    if @rating && @rating.save
      @job.purchase(@contractor) if params[:rating][:purchased_by].present?
      flash[:notice] = _('Ratings submitted!')
      @success = 'rating_success'
      redirect_to commercial_job_path(locale: current_locale_country, id: @job.id, success: @success)
    elsif @rating
      flash.now[:error] = @rating.errors.full_messages.to_sentence
      render 'commercial/ratings/new'
    else
      flash[:error] = "Contractor already rated"
      redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
    end
  end

  def request_a_rating
    @contractor = current_account.contractor
    RatingMailer.request_for_rating(@job, @contractor).deliver
    flash[:notice] = _('Rating request sent!')
    redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
  end

  private

  def ensure_correct_contractor
    unless current_account.contractor? &&
        @job.bids.find_by(contractor_id: current_account.contractor.id).present?
      flash[:warning] = _("You have no permission to access this site.")
      redirect_to job_path(locale: current_locale_country, id: @job.id)
    end
  end

  def ensure_correct_homeowner
    unless @job && @job.homeowner_id == current_account.id
      flash[:warning] = _("You have no permission to access this site.")
      redirect_to job_path(locale: current_locale_country, id: @job.id)
    end
  end

  def find_job
    @job = Commercial::Job.find(params[:job_id])
    @contractor = Contractor.find(params[:contractor_id]) if params[:contractor_id]
  end

  def find_contactor
    @contractor = Contractor.find(params[:contractor_id])
  end

  def rating_params
    params.require(:rating).permit('professionalism', 'quality', 'value', 'comments', 'contractor_id')
  end

end
