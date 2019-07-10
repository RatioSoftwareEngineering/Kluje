class Commercial::ClarificationsController < ApplicationController

  before_action :find_job
  before_action :find_accounts, only: [:update]

  def new
    @clarification = Clarification.new()
  end

  def create
    @contractor = current_account.contractor
    @clarification = @job.clarifications.new(clarification_params.merge(job_id: @job.id, contractor_id: @contractor.id))
    if @clarification.save
      flash[:success] = 'Your Clarification question has been sent to respective Client'
      CommercialMailer.notify_client_job_clarification(@job.homeowner, @contractor, @clarification).deliver
    else
      flash[:error] = 'Unable to submit your Question. Please try again.'
    end
    redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
  end

  def edit
    @clarification = Clarification.find(params[:id])
  end

  def update
    if @clarification.update_attributes(clarification_params)
      flash[:success] = 'Your Answer has been sent to respective Contractor'
      CommercialMailer.notify_contractor_job_clarification(@client, @contractor, @clarification).deliver
    else
      flash[:error] = 'Unable to submit your Answer, please try again.'
    end
    redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
  end

  private

  def find_job
    @job = Commercial::Job.find(params[:clarification][:job_id])
  end

  def find_accounts
    @clarification = Clarification.find(params[:id])
    @contractor = @clarification.contractor
    @client = @job.homeowner
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

  def clarification_params
    params.require(:clarification).permit(:question, :answer)
  end
end
