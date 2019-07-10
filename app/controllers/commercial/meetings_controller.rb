class Commercial::MeetingsController < CommercialController
  before_action :authenticate_account!
  before_action :find_job
  before_action :require_country_code, only: [:new]

  def new
    @meeting = @job.meetings.new()
  end


  def create
    if current_account.contractor?
      @client = @job.homeowner
      @contractor = current_account.contractor
      @meeting = @job.meetings.create(meeting_params.merge(job_id: @job.id, contractor_id: @contractor.id))
      if @meeting.save
        flash[:success] = 'Your Meeting has been sent to the Client.'
        CommercialMailer.notify_client_meeting_scheduled(@client, @contractor, @meeting).deliver
        redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
      else
        flash[:error] = 'Unable to submit your meeting. Please try again.'
        render :new
      end
    elsif current_account.homeowner?
      @client = current_account
      @contractor = Contractor.find(params[:meeting][:contractor_id])
      @meeting = @job.meetings.create(meeting_params.merge(job_id: @job.id, contractor_id: @contractor.id))
      if @meeting.save
        flash[:success] = 'Your Meeting has been sent to the Contractor.'
        CommercialMailer.notify_contractor_meeting_scheduled(@client, @contractor, @meeting).deliver
      else
        flash[:error] = 'Unable to submit your meeting. Please try again.'
      end
      redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
    end
  end

  def update
    @meeting = Meeting.find(params[:id])
    if @meeting.update_attributes(meeting_params)
      flash[:success] = 'Meeting has been accepted'
    else
      flash[:error] = 'Unable to accept meeting. Please try again.'
    end
    redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
  end

  def show

  end

  private

  def find_job
    @job = Commercial::Job.find(params[:job_id])
  end

  def meeting_params
    params.require(:meeting).permit(:date, :time, :place, :accept, :homeowner_id)
  end

end
