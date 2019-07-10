module Api
  class ContractorsController < BaseController
    skip_before_action :authenticate, only: [:create]

    def credit
      render json: { credit_balance: current_account.contractor.credits_balance }.to_json
    end

    def create
      @skills = []
      if params[:account].present? && params[:account][:contractor].present?
        if params[:account][:contractor][:skills].present?
          params[:account][:contractor][:skills].split(',').map {|i| @skills << Skill.find_by_id(i) }
          params[:account][:contractor].except! 'skills'
        else
          @skills = Skill.all
        end
        params[:account][:contractor_attributes] =  params[:account][:contractor];

        number = params[:account][:mobile_number]
        code = params[:account][:verification_code]

        params[:account].except!('contractor', 'mobile_number', 'verification_code')

        @account = Account.new(account_params)
        @account.role = 'contractor'
        @account.no_of_account = 2
        @account.contractor.mobile_alerts = false
        @account.contractor.is_deactivated = false
        @account.contractor.sms_count = 99

        if @skills.present? && @account.save
          @account.contractor.skills.destroy_all
          @skills.each do |skill|
            ContractorsSkill.create(skill: skill, contractor: @account.contractor)
          end
          @account.country.cities.available.each do |city|
            ContractorsCity.create contractor: @account.contractor, city: city
          end

          @account.verify_mobile(number, code) if number && code
          @account.contractor.reload

          sign_in(@account, bypass: true)
          render 'api/v1/contractors/create'
        else
          @account.valid?
          @account.errors.add(:skills, _('required')) if @skills.empty?
          ActiveRecord::Base.include_root_in_json = false
          render status: 400, json: @account.errors.as_json
        end
      else
        render status: 400, json: {}
      end
    end

    def skills
      @skills = @contractor.skills
      render 'api/v1/contractors/skills'
    end

    def change_skills
      skills = params[:skills].split(',')
      @contractor.skills.destroy_all
      skills.each do |skill_category_id|
        ContractorsSkill.create(:skill_id => skill_category_id.to_i, :contractor_id => @contractor.id)
      end
      @contractor.reload
      @skills = @contractor.skills
      render 'api/v1/contractors/skills'
    end

    def company_details
      render 'api/v1/contractors/company_details'
    end

    def change_company_details
      params[:contractor][:company_name] = @contractor.company_name
      params[:contractor][:nric_no] = @contractor.nric_no
      if @contractor.update_attributes(contractor_params)
        render json: @contractor.as_json(:only => [:company_name,:uen_number,:company_street_name,:company_unit_no,:company_building_name,:company_postal_code])
      else
        render status: 400, json: @contractor.errors.as_json
      end
    end

    def account_details
      render 'api/v1/contractors/account_details'
    end

    def change_account_details
      if params[:account].present?
        ['password', 'password_confirmation'].each{ |key| params[:account].delete(key) if params[:account][key].blank? }
      end
      if @account.update_attributes(account_params)
        render 'api/v1/contractors/account_details'
      else
        render status: 400, json: @account.errors.as_json
      end
    end

    def jobs
      if @contractor && @contractor.is_eligible_to_purchase_leads?
        jobs = @contractor.job_leads
      else
        errors = {}
        errors['skills'] = ['can\'t be empty'] if @contractor.skills.empty?
        errors['company_details'] = ['are not completed'] unless @contractor.company_details_completed?
        return render(status: 400, json: errors)
      end
      jobs.map!{ |job| job.as_json.merge(lead_price: job.lead_price) }
      render json: jobs.as_json
    end

    def photo
      ActiveRecord::Base.include_root_in_json = false
      begin
        @job = Residential::Job.find(params[:id])
        @photos = @job.photos
        render 'api/v1/homeowners/jobs/photos'
      rescue ActiveRecord::RecordNotFound
        render status: 401, json: {}
      end
    end

    def job
      begin
        @job = Residential::Job.find(params[:id].to_i)
      rescue ActiveRecord::RecordNotFound
        return render(status: 401, json: {})
      end
      render 'api/v1/contractors/jobs/show'
    end

    def purchased_leads
      @jobs = @contractor.bids.sort_by(&:created_at).reverse.map(&:job)
      @job_data = []
      @jobs.each do |job|
        if job.homeowner
          obj = JSON.parse(job.to_json)
          obj['homeowner_name'] = "#{job.homeowner.first_name} #{job.homeowner.last_name}"
          obj["homeowner_email"] = job.homeowner.email
          obj['homeowner_mobile_number'] = job.homeowner.mobile_number
          @job_data << obj
        end
      end
      render json: @job_data.to_json
    end

    def my_ratings
      @ratings = @contractor.ratings
      @rating_data  = []
      @ratings.each do |rating|
        obj = JSON.parse(rating.to_json)
        obj['job'] = rating.job if rating.job.present?
        if rating.job.present?
          obj['homeowner'] = "#{rating.job.homeowner.first_name} #{rating.job.homeowner.last_name}" if rating.job.homeowner.present?
        end
        @rating_data << obj
      end
      render json: @rating_data.as_json
    end

    def ratings
      @contractor = Contractor.find(params[:id])
      @ratings = @contractor.ratings if @contractor
      @rating_data  = []
      @ratings.each do |rating|
        obj = JSON.parse(rating.to_json)
        obj['job'] = rating.job if rating.job.present?
        if rating.job.present?
          obj['homeowner'] = "#{rating.job.homeowner.first_name} #{rating.job.homeowner.last_name}" if rating.job.homeowner.present?
        end
        @rating_data << obj
      end
      render json: @rating_data.as_json
    end

    def bid_job
      begin
        @job = Residential::Job.approved.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        return render(status: 404, json: { job: ["not found"] })
      end
      if @job.can_accept_bid? && @contractor.can_bid_for_job?(@job)
        @job.accept_bid(@contractor)
        render 'api/v1/contractors/jobs/show'
      else
        unless @contractor.account.email_verified?
          @contractor.errors.add(:email, _('Not verified'))
        end
        if @contractor.account.suspended?
          @contractor.errors.add(:account, _('Has been suspended'))
        end
        if @contractor.has_bidded_for_job?(@job)
          @contractor.errors.add(:bid, _('You have already bidded for this job'))
        end
        if @contractor.credits_balance < @job.lead_price
          @contractor.errors.add(:credit, _("You don't have enough credits to purchase this lead"))
        end
        render status: 400, json: @contractor.errors.as_json
      end
    end

    def request_rating
      @job = Residential::Job.find_by_id(params[:id])
      if @job
        ActiveRecord::Base.include_root_in_json = false
        begin
          if !@job.homeowner.nil?
            RatingMailer.request_for_rating(@job, @contractor).deliver
            @job.homeowner.notify "Your contractor request for rating. Job #{@job.id}"
          end
          render json: @job.as_json
        rescue Exception => e
          @job.errors.add(:rating,_('Your rating request was not sent because an error occurred, please try again later.'))
          return render(status: 401, json: @job.errors.as_json)
        end
      else
        render status: 401, json: {}
      end
    end

    def change_password
      ActiveRecord::Base.include_root_in_json = false
      @account = ApiKey.find_by_access_token(request.env['HTTP_ACCESS_TOKEN']).account
      if !@account.valid_password?(params[:current_password])
        @account.errors.add(:password, "Missing Password.")
        render status: 400, json: @account.errors.as_json
      else
        if @account.update_attributes(account_params)
          render 'api/v1/contractors/change_password'
        else
          render status: 400, json: @account.errors.as_json
        end
      end
    end

    def profile
      if params[:id]
        @account = Contractor.find(params[:id]).account
      else
        api_key = ApiKey.find_by_access_token(request.env['HTTP_ACCESS_TOKEN'])
        @account = api_key.account unless api_key.nil?
      end

      if @account
        ActiveRecord::Base.include_root_in_json = false
        @profile_data = Hash.new
        @profile_data['account'] = @account
        @profile_data['contractor'] = @account.contractor
        @profile_data['skills'] = @account.contractor.skills.map(&:id)
        @profile_data['ratings'] = @account.contractor.ratings.map(&:id)
        render json: @profile_data.as_json
      else
        render status: 401, json: {}
      end
    end

    def billing
      api_key = ApiKey.find_by_access_token(request.env['HTTP_ACCESS_TOKEN'])
      @account = api_key.account unless api_key.nil?
      if @account
        @billing_data = {
                         cmd: '_xclick',
                         business: Settings['paypal']['business_email'],
                         currency_code: 'SGD',
                         no_shipping: 1,
                         no_note: 1,
                         tax: 0,
                         rm: 1,
                         cpp_cart_border_color: 'f8a92d',
                         cpp_logo_image: Kluje.settings.host + '/assets/kluje_paypal.png',
                         notify_url: Kluje.settings.host + Kluje.url(:payments, :notify),
                         return: Kluje.settings.host + Kluje.url(:contractor, :billing, action: 'top_up'),
                         cancel_return: Kluje.settings.host + Kluje.url(:contractor, :billing, show: 'top_up_account'),
                        }
        ActiveRecord::Base.include_root_in_json = true
        render json: @billing_data.as_json
      end
    end

    def sms_status
      api_key = ApiKey.find_by_access_token(request.env['HTTP_ACCESS_TOKEN'])
      @account = api_key.account unless api_key.nil?
      if @account
        @contractor = @account.contractor
        ActiveRecord::Base.include_root_in_json = false
        render json: @contractor.as_json(:only => [ :id,:is_deactivated,:mobile_alerts,:sms_count ])
      else
        render status: 401, json: {}
      end
    end

    def update_sms_alert
      api_key = ApiKey.find_by_access_token(request.env['HTTP_ACCESS_TOKEN'])
      @account = api_key.account unless api_key.nil?
      if @account
        if params[:account][:mobile_alert] == '1'
          @account.contractor.is_deactivated = false
          @account.contractor.mobile_alerts = true
          if @account.contractor.save
            render json: @account.contractor.as_json(:only => [ :id,:is_deactivated,:mobile_alerts])
          else
            @errors = _(@account.contractor.errors.full_messages) unless @account.contractor.errors.empty?
            return render(status: 400, json: @errors.as_json)
          end
        else
          @account.contractor.is_deactivated = true
          @account.contractor.mobile_alerts = false
          if @account.contractor.save
            return render json: @account.contractor.as_json(:only => [ :id,:is_deactivated,:mobile_alerts])
          else
            @errors = _(@account.errors.full_messages) unless @account.errors.empty?
            return render(status: 400, json: @errors.as_json)
          end
        end
      else
        render status: 401, json: {}
      end
    end

    private

    def account_params
      contractor_attributes = [:company_name, :nric_no, :uen_number,
                               :company_street_no, :company_street_name,
                               :company_unit_no, :company_building_name,
                               :company_postal_code, :bca_license, :hdb_license,
                               :account_attributes, :mobile_alerts,
                               :email_alerts, :company_description,
                               :company_logo, :pub_license, :ema_license,
                               :case_member, :scal_member, :bizsafe_member,
                               :selected_header_image, :sms_count,
                               :is_deactivated, :office_number, :photo_id,
                               :business_registration, :selected_header_image,
                               :company_logo]
      params.require(:account).permit(:first_name, :last_name, :email,
                                      :password, :mobile_number, :country_id,
                                      contractor_attributes: contractor_attributes )
    end

    def contractor_params
      contractor_attributes = [:company_name, :nric_no, :uen_number,
                               :company_street_no, :company_street_name,
                               :company_unit_no, :company_building_name,
                               :company_postal_code, :bca_license, :hdb_license,
                               :account_attributes, :mobile_alerts,
                               :email_alerts, :company_description,
                               :company_logo, :pub_license, :ema_license,
                               :case_member, :scal_member, :bizsafe_member,
                               :selected_header_image, :sms_count,
                               :is_deactivated, :office_number, :photo_id,
                               :business_registration, :selected_header_image,
                               :company_logo]

      params.require(:contractor).permit(*contractor_attributes, account_attributes:
                                         [:email, :country_id, :password,
                                          :password_confirmation, :first_name,
                                          :last_name, :id])
    end
  end
end
