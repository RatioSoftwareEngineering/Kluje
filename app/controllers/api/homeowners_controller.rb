module Api
  class HomeownersController < BaseController
    before_action :set_homeowner
    skip_before_action :authenticate, only: [:create, :login_with_social]

    def show
      render 'api/v1/homeowners/show'
    end

    def lead_jobs
      @jobs = Residential::Job.where("state = ? or state = ?",'bidded','approved').order("created_at DESC").limit(50)
      render json: @jobs.as_json
    end

    def create
      @account = Account.new(account_params)
      @account.role = 'homeowner'
      if @account.save
        render 'api/v1/homeowners/create'
      else
        render status: 400, json: @account.errors.to_json
      end
    end

    def edit
      render 'api/v1/homeowners/edit'
    end

    def update
      if @homeowner.update_attributes(account_params)
        render 'api/v1/homeowners/update'
      else
        render status: 400, json: @homeowner.errors.as_json
      end
    end

    def change_password
      if !Account.authenticate @homeowner.email, params[:current_password]
        @homeowner.errors.add(:base, "Missing Password.")
        render status: 400, json: @homeowner.errors.as_json
      else
        if @homeowner.update_attributes(account_params)
          render 'api/v1/homeowners/change_password'
        else
          render status: 400, json: @homeowner.errors.as_json
        end
      end
    end

    def jobs
      @jobs = Residential::Job.where(homeowner_id: @homeowner.id).includes(:photos).includes(:bids).order(created_at: :desc)
      @job_data = []
      @jobs.each do |job|
        obj = JSON.parse(job.to_json)
        obj['number_bids'] = job.bids.length unless job.bids.empty?
        photos = []
        photos = job.photos.map(&:image_name_url).compact
        obj['photos'] = photos
        @job_data << obj
      end
      render json: @job_data.as_json
    end

    def bidded_jobs
      @jobs = Residential::Job.where(state: 'bidded').where(homeowner_id: @homeowner.id).order(created_at: :desc)
      render json: @jobs.as_json
    end

    def job
      begin
        @job = Residential::Job.find(params[:id])
        return render(status: 403, json: {}) if @job.homeowner != current_account
      rescue ActiveRecord::RecordNotFound
        return render(status: 404, json: {})
      end
      render 'api/v1/homeowners/jobs/show'
    end

    def edit_job
      begin
        @job = @homeowner.jobs.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        return render(status: 404, json: {})
      end
      render 'api/v1/homeowners/jobs/show'
    end

    def bidded_job
      @contractors = []
      begin
        job = Residential::Job.find(params[:id])
        bids = job.bids
        unless bids.empty?
          bids.each do |bid|
            obj = JSON.parse(bid.contractor.to_json) unless bid.contractor.nil?
            obj['bidded_at'] = bid.created_at
            obj['account'] = JSON.parse(bid.contractor.account.to_json)
            @contractors << obj
          end
        end
      rescue ActiveRecord::RecordNotFound
        return render(status: 404, json: { job: ["not found"] })
      end
      render json: @contractors.as_json
    end

    def update_job
      @homeowner.mobile_number = params[:job][:mobile_number] if params[:job] && params[:job][:mobile_number].present?
      @job = @homeowner.jobs.find(params[:job][:id])
      params[:job].delete('mobile_number')
      params[:job].delete('city_id') if City.find_by(id: params[:job][:city_id]).blank?

      if @job && @job.update_attributes(job_params) && @homeowner.save
        render 'api/v1/homeowners/jobs/update'
      else
        render status: 400, json: @job.errors.as_json
      end
    end

    def create_job
      @homeowner.mobile_number = params[:job][:mobile_number] if params[:job] && params[:job][:mobile_number].present?
      params[:job].delete('mobile_number')
      @job = Residential::Job.new(job_params)

      @job.homeowner_id = @homeowner.id
      unless @homeowner.jobs.empty?
        @job.postal_code = @homeowner.jobs.first.postal_code
      end

      if @job.save && @homeowner.save
        images = params.select{|k,v| k =~ /image[1-5]{0,1}/}.map{|k,v| v}
        images.each do |image|
          @job.photos.create image_name: image
        end
        render 'api/v1/homeowners/jobs/create'
      else
        if @job.errors.any?
          render status: 400, json: @job.errors.as_json
        end
      end
    end

    def change_job
      @old_job = Residential::Job.find(params[:id].to_i)
      action = request.env["action_dispatch.request.query_parameters"][:action]
      if action == 'repost'
        @job = @old_job.dup
        @job.state = 'approved'
        @job.touch(:approved_at)
        if @job.save
          @old_job.archive if @old_job
          RepostJob.create(:new_job_id => @job.id,:old_job_id=> @old_job.id)
          @old_job.send_for_moderation
          render 'api/v1/homeowners/jobs/show'
        else
          render status: 400, json: @job.errors.as_json
        end
      elsif action == 'cancel'
        if @old_job.archive
          @old_job.send_for_moderation
          render 'api/v1/homeowners/jobs/show'
        else
          render status: 400, json: @job.errors.as_json
        end
      else
        render status: 400, json: "incorrect action #{action}"
      end
    end

    def login_with_social
      fail UnprocessableEntity.new({ params: 'missing' }.to_json) unless params[:provider].present? && params[:auth_token].present?

      data = AuthorizationService.check params[:provider], params[:auth_token]
      fail Unauthorized.new({ uid: ["Couldn't be verified"] }.to_json) if data.blank? || data[:uid] != params[:uid]

      @account = Account.find_by_provider_and_uid(data[:provider], data[:uid]) if data[:provider].present? && data[:uid].present?
      @account ||= Account.find_by_email(data[:email]) if data[:email].present?

      unless @account
        @account = Account.new( provider: params[:provider], uid:  params[:uid],
                               first_name: params[:first_name],
                               last_name:  params[:last_name],
                               email: params[:email], role: "homeowner",
                               confirmed_at: Time.now )
        return render(status: 403, json: @account.errors.as_json) unless @account.save
      end

      [:uid, :provider, :email].each do |param|
        @account.update_attribute(:param, data[:param]) if @account[param].blank?
      end

      @account.generate_api_key if @account.api_key.nil?
      @device = @account.add_device params[:platform], params[:device_token]
      @account.reload
      render 'api/v1/homeowners/create'
    end


    private

    def account_params
      params.require(:account).permit(:first_name, :last_name,
                                      :email, :password,
                                      :mobile_number, :country_id)
    end

    def job_params
      params.require(:job).permit('homeowner', 'city_id', 'skill_id', 'job_category_id', 'description',
                                  'availability_id', 'budget_id', 'postal_code',
                                  'contact_time_id', 'property_type')
    end

    def set_homeowner
      @homeowner = current_account
    end
  end
end
