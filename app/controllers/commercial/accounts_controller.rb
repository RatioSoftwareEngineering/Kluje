class Commercial::AccountsController < CommercialController
  before_action :require_country_code, only: [:show]
  
  def show
    if current_account.try(:homeowner?)
      params[:show] = 'account_details'
      render 'homeowners/account/details', layout: '../commercial/account/layout'
    elsif current_account.try(:contractor?)
      render 'contractors/account/account_details'
    else
      flash[:notice] = _('Log in before continuing')
      session[:return_to] = request.url
      redirect_to new_account_session_path
    end
  end
end
