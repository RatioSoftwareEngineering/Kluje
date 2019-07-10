class AccountsController < ApplicationController
  before_action :require_country_code, only: [:show]

  def show
    if current_account.try(:homeowner?)
      params[:show] = 'account_details'
      render 'homeowners/account/details', layout: '../homeowners/account/layout'
    elsif current_account.try(:contractor?)
      render 'contractors/account/account_details'
    else
      flash[:notice] = _('Log in before continuing')
      session[:return_to] = request.url
      redirect_to new_account_session_path
    end
  end

  def change_password
    if !current_account.valid_password?(params[:account][:old_password])
      flash[:error] = "Current password incorrect"
    elsif params[:account][:password] != params[:account][:password_confirmation]
      flash[:error] = "Password confirmation doesn't match new password"
    elsif current_account.update_attributes(password: params[:account][:password])
      sign_in current_account, :bypass => true
      flash[:notice] = _('Password updated!')
    elsif current_account.errors
      flash[:error] = current_account.errors.full_messages
    end
    redirect_to request.env['HTTP_REFERER']
  end
end
