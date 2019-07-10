# rubocop:disable Metrics/ClassLength
class ContractorsController < ApplicationController
  before_action :ensure_verified, except: [:new, :create, :message_confirmation,
                                           :send_sms_code, :profile,
                                           :signup_success, :members,
                                           :how_it_works, :faq]
  before_action :require_country_code, only: [:members, :profile, :ratings, :account_details, :verification_request, :top_up, :billing_history, :skills, :change_password, :commercial_request, :notifications, :locations]

  def new
    @account = Account.new
    @account.contractor = Contractor.new
    @skills = []
    render 'contractors/signup'
  end

  def create
    @account = Account.new(account_params)
    @account.role = 'contractor'

    @account.contractor.mobile_alerts = false
    @account.contractor.is_deactivated = false
    @account.contractor.sms_count = 99

    if @account.save
      @account.contractor.skills.destroy_all
      Skill.all.each do |skill, _value|
        ContractorsSkill.create(skill_id: skill.id.to_i, contractor_id: @account.contractor.id)
      end
      @account.country.cities.available.each do |city|
        ContractorsCity.create contractor: @account.contractor, city: city
      end
      @account.contractor.reload
      flash.now[:notice] = _('Thank you for signing up for kluje.com!')
      render 'home/verify_email'
    else
      flash.now[:notice] = @account.errors.full_messages[0]
      render 'contractors/signup'
    end
  end

  ############# Accept User Agreement
  def accept_agreement
    @contractor = current_account.contractor
    # @contractor.accept_agreement = params[:accept_agreement]
    if @contractor.update_attributes(contractor_params)
      flash.now[:notice] = _('Thank you for signing up for kluje commercial!')
      redirect_to commercial_jobs_path(locale: current_locale_country)
    else
      redirect_to account_details_contractors_path(locale: current_locale_country)
    end
  end

  ########################### Request
  def verification_request
    add_brochures_projects
    render 'contractors/account/verification_request', layout: '../contractors/account/layout'
  end

  def form_verification_request
    if @contractor.update_attributes(contractor_params)
      VerificationMailer.thank_contractor_verification_request(@contractor).deliver_now
      redirect_to jobs_path(locale: current_locale_country), flash: {
        success: _('Thank you for your verification request! We will notify you once we have checked your details.')
      }
    else
      flash.now[:notice] = _('Please complete the form before send request.')
      add_brochures_projects
      render 'contractors/account/verification_request', layout: '../contractors/account/layout'
    end
  end

  def commercial_request
    if current_account.contractor.verified?
      render 'contractors/account/commercial_request', layout: '../contractors/account/layout'
    else
      add_brochures_projects
      flash.now[:notice] = _('Please complete the verification form before apply Kluje commercial.')
      render 'contractors/account/verification_request', layout: '../contractors/account/layout'
    end
  end

  def form_commercial_request
    if @contractor.update_attributes(contractor_params)
      redirect_to jobs_path(locale: current_locale_country), flash: {
        success: _('Thank you for your commercial request! We will notify you once we have checked your details.')
      }
    else
      flash.now[:notice] = _('Please complete the form before send request.')
      render 'contractors/account/request_commercial', layout: '../contractors/account/layout'
    end
  end
  ############# Acount edit

  [:account_details, :locations, :skills, :change_password, :notifications].each do |page|
    define_method(page) do
      @skills = current_account.contractor.skill_ids
      render "contractors/account/#{page}", layout: '../contractors/account/layout'
    end
  end

  def update_account_details
    contractor = current_account.contractor
    params[:contractor].delete('subscribe_newsletter')
    params[:contractor][:company_name] = contractor.company_name
    params[:contractor][:nric_no] = contractor.nric_no

    if contractor.update_attributes(contractor_params)
      flash[:notice] = _('Account settings updated!')
      redirect_to account_details_contractors_path(locale: current_locale_country)
    else
      render 'contractors/account/account_details', layout: '../contractors/account/layout'
    end
  end

  def change_skills
    contractor = current_account.contractor
    params[:skill].reject! { |_k, v| v == '0' }

    if params[:skill]
      contractor.skills.destroy_all
      params[:skill].each do |skill_category_id, _value|
        contractor.contractor_skills.create(skill_id: skill_category_id)
      end
      flash[:notice] = _('Account settings updated!')
      redirect_to skills_contractors_path(locale: current_locale_country)
    else
      flash[:error] = _('Please select at least one skill')
      redirect_to request.env['HTTP_REFERER']
    end
  end

  def update_alerts
    contractor = current_account.contractor
    [:mobile_alerts, :email_alerts].each do |alert_type|
      alerts = params[:account][alert_type].to_s
      if alerts == '1' || alerts == 'true'
        contractor.update_attribute(alert_type, true)
        contractor.update_attribute(:is_deactivated, false)
      elsif alerts == '0' || alerts == 'false'
        contractor.update_attribute(alert_type, false)
      end
    end
    flash[:success] = 'Your notifications settings were successfully updated'
    redirect_to request.env['HTTP_REFERER']
  end

  ############################################## Jobs

  def ratings
    @contractor = current_account.contractor
    if request.path =~ /commercial/
      @ratings = @contractor.ratings.approved.commercial
      render 'contractors/jobs/ratings', layout: '../commercial/contractors/jobs/layout'
    else
      @ratings = @contractor.ratings.approved.residential
      render 'contractors/jobs/ratings', layout: '../contractors/jobs/layout'
    end
  end

  ########################### Billing

  def top_up
    fields = payment_field.merge(cmd: '_xclick',
                                 return: billing_top_up_contractors_url(action: 'success'),
                                 cancel_return: billing_top_up_contractors_url(action: 'cancelled'))
    action = request.env['action_dispatch.request.query_parameters'][:action]
    if action == 'success'
      flash.now[:notice] = 'Thank you for topping up your account!
      Credit will be granted to your account within a few minutes.'
    end
    render 'contractors/billing/top_up', layout: '../contractors/billing/layout', locals: { fields: fields }
  end

  def subscription
    fields = payment_field.merge(
      p3: 1,
      t3: 'M',
      src: 1,
      modify: 0,
      cmd: '_s-xclick',
      return: billing_subscription_contractors_url(action: 'success'),
      cancel_return: billing_subscription_contractors_url(action: 'cancelled'),
      hosted_button_id: Settings['paypal']['residential_subscription_id'][current_country.cca2]
    )
    action = request.env['action_dispatch.request.query_parameters'][:action]
    flash.now[:notice] = 'Thank you for your subscription!' if action == 'success'
    render 'contractors/billing/subscription', layout: '../contractors/billing/layout', locals: { fields: fields }
  end

  def unsubscribe
    if @contractor.unsubscribe
      flash.now[:notice] = 'Unsubscribe successful'
    else
      flash.now[:notice] = 'Error has occurred. Please unsubscribe again'
    end
    @subscriptions = @contractor.subscriptions.order(expired_at: :desc).paginate(page: params[:page], per_page: 10)
    render 'contractors/billing/invoices', layout: '../contractors/billing/layout'
  end

  def invoices
    Subscription.reload(@contractor)
    @subscriptions = @contractor.subscriptions.order(expired_at: :desc).paginate(page: params[:page], per_page: 10)
    render 'contractors/billing/invoices', layout: '../contractors/billing/layout'
  end

  def show_invoice
    @subscription = Subscription.find_by(id: params[:id])

    respond_to do |format|
      format.pdf do
        pdf = SubscriptionInvoicePDF.new(@subscription, current_account)
        send_data pdf.render,
                  filename:    "#{@subscription.id}.pdf",
                  type:        'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def membership
    render 'contractors/billing/membership', layout: '../contractors/billing/layout'
  end

  def billing_history # rubocop:disable Metrics/AbcSize
    @contractor = current_account.contractor
    flash.now[:notice] = _('No activity to show') if @contractor.bids.empty? && @contractor.top_ups.empty?

    # time_zone = current_account.country.time_zone
    @entries = {}

    %w(bids top_ups feature_payments).each do |type|
      @contractor.send(type).where('amount IS NOT NULL AND amount <> 0').each do |entry|
        if type != 'top_ups' || entry.processed?
          time = entry.created_at
          (((@entries[time.year] ||= {})[time.month] ||= {})[type] ||= []) << entry
        end
      end
    end

    @earliest = [
      @contractor.top_ups.order(:created_at).pluck(:created_at).first,
      @contractor.bids.order(:created_at).pluck(:created_at).first,
      Time.zone.now
    ].compact.min.beginning_of_month

    @latest = [
      @contractor.top_ups.order(:created_at).pluck(:created_at).last,
      @contractor.bids.order(:created_at).pluck(:created_at).last,
      Time.zone.now
    ].compact.max.beginning_of_month

    render 'contractors/billing/history', layout: '../contractors/billing/layout'
  end

  ###################### Profile

  def profile_update
    @contractor = current_account.contractor
    @contractor.update_attributes(profile_params)

    if request.xhr?
      'ok'
    else
      @skills = @contractor.skill_ids
      @contractor.photos.create(image_name: params[:photo]) if params[:photo]
      redirect_to profile_contractors_path(locale: current_locale_country, slug: @contractor.company_name_slug, edit: true)
    end
  end

  def destroy_photo
    photo = @contractor.photos.find_by_id(params[:id])
    photo.destroy if photo
    redirect_to profile_contractors_path(locale: current_locale_country, slug: @contractor.company_name_slug, edit: true)
  end

  #############################

  def signup_success
    render 'contractors/signup_success'
  end

  def update_contractor # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    @account = current_account || Account.find(params[:account][:id])
    @contractor = @account.contractor
    if params[:button_action].to_s == 'RemoveImage' && !params[:selected_photos].nil?
      @photos = Photo.find(params[:selected_photos].split(','))
      Photo.delete @photos.map(&:id)
      flash[:notice] = _('Images are removed!')
      return redirect(profile_contractors_path(locale: current_locale_country, slug: @contractor.company_name_slug) + '#myCarouselSlider')
    end

    if params[:company_description]
      @contractor.company_description = params[:company_description]
      @contractor.save
    end

    if params[:photo]
      @photo = Photo.new(image_name: params[:photo])
      @photo.contractor_id = @account.contractor.id
      @photo.save
    end

    if params[:skill]
      contractor = @account.contractor
      chosen_skills = params[:skill].split(',')
      if !chosen_skills.empty?
        contractor.skills.destroy_all
        chosen_skills.each do |skill_category_id, _value|
          ContractorsSkill.create(skill_id: skill_category_id.to_i, contractor_id: contractor.id)
        end
        contractor.reload

        flash[:notice] = _('Account settings updated!')
        redirect(profile_contractors_path(locale: current_locale_country, slug: contractor.company_name_slug))
      else
        flash[:error] = _('Please select at least one skill')
        redirect_to request.env['HTTP_REFERER']
      end
    end

    unless params[:hdb_license].nil? || params[:bca_license].nil? || params[:uen_number].nil?
      params[:pub_license].nil? || params[:ema_license].nil? || params[:case_member].nil?
      params[:scal_member].nil? || params[:bizsafe_member].nil?
      if @contractor.update_attributes(
        company_name: @account.contractor.company_name,
        hdb_license: params[:hdb_license],
        bca_license: params[:bca_license],
        uen_number: params[:uen_number],
        pub_license: params[:pub_license],
        ema_license: params[:ema_license],
        case_member: params[:case_member],
        scal_member: params[:scal_member],
        bizsafe_member: params[:bizsafe_member]
      )

      elsif !@contractor.errors.empty?
        flash[:notice] = _(@contractor.errors.full_messages) unless @contractor.errors.empty?
        redirect(profile_contractors_path(locale: current_locale_country, slug: @contractor.company_name_slug))
      end
    end

    @contractor.update_attributes(company_logo: params[:company_logo]) unless params[:company_logo].nil?

    unless params[:selected_header_image].nil?
      @contractor.update_attributes(
        selected_header_image: params[:selected_header_image],
        crop_w: params[:crop_width],
        crop_h: params[:crop_height],
        crop_x: params[:crop_x], crop_y: params[:crop_y]
      )
    end

    if params[:contractor][:cities]
      city_ids = params[:contractor][:cities].map { |k, v| k.to_i if v == '1' }.compact

      contractor_cities = ContractorsCity.where(contractor_id: current_account.contractor_id)
      removed = contractor_cities.where('city_id NOT IN (?)', city_ids)
      removed.delete_all

      new =  city_ids - contractor_cities.pluck(:city_id)
      new.each do |city_id|
        ContractorsCity.create(contractor_id: @contractor.id, city_id: city_id)
      end

      flash[:notice] = _('Account settings updated!')
      redirect_to locations_contractors_path(locale: current_locale_country)
      return
    end

    if @photo
      if @photo.errors.present?
        flash[:notice] = _(@photo.errors.full_messages) unless @photo.errors.empty?
        redirect(@contractor.profile_url + '#myCarouselSlider')
      else
        flash[:msg] = _('Your photo is uploaded!')
        redirect(@contractor.profile_url + '#myCarouselSlider')
      end
    else
      flash[:notice] = _('Account settings updated!')
      redirect(@contractor.profile_url)
    end
  end

  def message_confirmation
    @account = current_account || Account.find_by_id(params[:id])
    return redirect_to jobs_path(locale: current_locale_country) if @account.present? && @account.mobile_verified?

    render 'contractors/message_confirmation'
  end

  # rubocop:disable Metrics/BlockNesting
  def send_sms_code # rubocop:disable Metrics/PerceivedComplexity
    @account = Account.find(params[:account][:id])
    if @account
      @account.mobile_number = params[:account][:mobile_number]
      if @account.save
        if @account.mobile_number.nil?
          flash[:notice] = 'Please enter you mobile number'
        else
          session[:sms_confirm_code] = @account.generate_sms_confirm_code
          if session.key?(:sms_confirm_code)
            @account.sms "Confirmation code for kluje mobile alert : #{session[:sms_confirm_code]}"
          end
        end
      else
        flash[:notice] = _(@account.errors.full_messages) unless @account.errors.empty?
      end
    else
      flash[:notice] = 'Something want wrong.'
    end
    render 'contractors/message_confirmation'
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def profile
    country = locale_country
    @contractor = Contractor.country(country.id)

    if params[:slug]
      @contractor = Contractor.includes(ratings: :job).country(country.id).find_by_company_name_slug(params[:slug])
    elsif current_account.try(:contractor?)
      @contractor = current_account.contractor
    end

    unless @contractor && @contractor.account
      if params[:slug] == 'jobs'
        redirect_to jobs_path(locale: current_locale_country)
        return
      end
      if params[:slug] == 'profile'
        redirect_to @contractor.profile_url
        return
      end
      if params[:slug] == 'my_ratings'
        redirect_to ratings_contractors_path(locale: current_locale_country)
        return
      end

      # flash[:notice] = _('Contractor %s not found') % (params[:slug] && params[:slug].underscore.humanize.titleize)
      # redirect_to members_path(locale: current_locale_country, category: :all)

      need_to_redirect = session.delete(:redirect_to_target)
      if need_to_redirect
        return redirect_to members_path(locale: current_locale_country, category: :all)
      else
        return error404
      end
      # error404
      # return
    end

    @skills = @contractor.skill_ids
    @show_contact_details = current_account.try(:homeowner?) && \
                            current_account.known_contractor_ids.include?(@contractor.id)
    render 'contractors/profile/index'
  end

  ####################### Info pages

  def members
    # City.available.each do |city|
    #   @city = city if city.name.parameterize == params[:city]
    # end
    @country = Country.find_by(cca2: params[:locale][-2..-1]) || current_country || Country.find_by(name: 'Singapore')

    @country.cities.available.each do |city|
      @city = city if city.name.parameterize == params[:city]
    end


    params[:city] = @city.try(:name).try(:parameterize).try(:underscore)

    Skill.all.each do |skill|
      @skill = skill if skill.name.parameterize == params[:category]
    end

    if @skill
      @contractors = @skill.contractors.includes(account: :country).country(@country.id).top
    else
      @contractors = Contractor.includes(account: :country).country(@country.id).top
    end
    @contractors = @contractors.city(@city.id) if @city

    page = params[:page].to_i
    page = 1 if page < 1

    # for filters
    @cities = @country.cities.available.map { |c|  {id: c.name.parameterize , name: c.name} }
    @skills = Skill.all.map { |s| {id: s.name.parameterize, name: s.name } }


    @contractors = @contractors.includes(:skills).paginate(page: page, per_page: 30)
  end

  def how_it_works
    render 'contractors/how_it_works'
  end

  def faq
    render 'contractors/faq'
  end

  private

  def account_params
    params.require(:account).permit(:email, :country_id, :password,
                                    :password_confirmation, :first_name,
                                    :last_name,
                                    contractor_attributes: [:company_name])
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
                             :company_logo, :accept_agreement, :request_commercial,
                             :company_red, :company_rn, :company_rd, :date_incor,
                             :association_name,
                             :membership_no, :verification_request]

    params.require(:contractor).permit(*contractor_attributes, account_attributes:
                                      [:email, :country_id, :password,
                                       :password_confirmation, :first_name,
                                       :last_name, :id],
                                                               company_brochures_attributes: [:id, :file],
                                                               company_projects_attributes: [:id, :file])
  end

  def ensure_verified
    if signed_in?
      @account = current_account
      @contractor = current_account.contractor
      if !current_account.email_verified?
        redirect_to new_account_confirmation_path
      elsif current_account.mobile_number.nil?
        redirect_to message_confirmation_contractors_path(msg: 'new', id: current_account.id)
      elsif current_account.suspended?
        sign_out
        flash[:error] = _('Your account has been suspended')
        redirect_to home_path
      end
    else
      flash[:notice] = _('Log in before continuing')
      session[:return_to] = request.url
      redirect_to new_account_session_path
    end
  end

  def profile_params
    params.permit(:selected_header_image, :company_logo, :company_description)
  end

  def accept_params
    params.permit(:accept_agreement)
  end

  def add_brochures_projects
    2.times { @contractor.company_brochures.build } unless @contractor.company_brochures.present?
    4.times { @contractor.company_projects.build } unless @contractor.company_projects.present?
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
      notify_url: notify_payments_url
    }
  end
end
