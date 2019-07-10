class AgentsController < ApplicationController

  def new
    @account = Account.new
    render 'agents/signup'
  end

  def create
    @account = Account.new(agent_params)
    @account.role = 'homeowner'
    @account.agent = 1
    @account.partner_code = SecureRandom.urlsafe_base64(9)

    if params[:account]
      mobile_number = params[:account][:mobile_number]
      country = Country.find_by_id(params[:account][:country_id])
      mobile_number = Textable.normalize(mobile_number, default_phone_code: country.default_phone_code)
      if mobile_number.present?
        @account.mobile_number = mobile_number
      else
        flash.now[:warn] = 'Incorrect mobile number. Please contact us if the problem persists.'
        return render 'agents/signup'
      end
    end

    if @account.save
      flash.now[:notice] = _('Thank you for signing up for kluje.com!')
      render 'home/verify_email'
    else
      flash.now[:notice] = @account.errors.full_messages[0]
      render 'agents/signup'
    end
  end


  private

  def agent_params
    params.require(:account).permit(:email, :country_id, :password,
                                    :password_confirmation, :first_name,
                                    :last_name, :mobile_number, :partner_code, :agent)
  end

  def ensure_verified
    if signed_in?
      @account = current_account
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

end
