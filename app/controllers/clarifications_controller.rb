class ClarificationsController < ApplicationController
  def new
    @clarification = Clarification.new()
  end
  def create
    @job = Commercial::Job.approved.find(params[:job_id])
    @contractor = current_account.contractor
    @clarification = job.clarifications.new(clarification_params.merge(job_id: job.id, contractor_id: contractor.id))
    if @clarification.save
      flash[:success] = 'Your Clarification question has been sent to the Client.'
    else
      flash[:error] = 'Unable to submit your question. Please try again.'
    end
  end
  def edit
    @clarification = Clarification.find(params[:id])
  end
  def update
    @clarification = Clarification.find(params[:id])
    if @clarification.update_attributes(clarification_params)
      flash[:success] = 'Clarification was updated'
    else
      flash[:error] = 'Unable to submit, please try again.'
    end
    redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
  end

  private
  def clarification_params
    params.require(:clarification).permit(:question, :answer)
  end
end