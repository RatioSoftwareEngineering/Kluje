class HomeownersController < ApplicationController
  include ApplicationHelper

  before_action :ensure_signed_in, only: [:update]

  def update
    ['password', 'password_confirmation'].each{ |key| params[:account].delete(key) if params[:account][key].blank? }
    if current_account.update_attributes(account_params)
      if current_account.mobile_number.nil?
        flash[:notice] = _('Invalid mobile number')
        redirect_to account_path(locale: current_locale_country)
      else
        flash[:notice] = _('Account settings updated!')
        redirect_to account_path(locale: current_locale_country)
      end
    else
      render 'homeowners/my_account'
    end
  end

  def how_it_works
    render "homeowners/how_it_works"
  end

  def faq
    render "homeowners/faq"
  end

  def checklist
    render "homeowners/checklist"
  end

  private

  def account_params
    params.require(:account).permit(:email, :country_id, :password,
                                    :password_confirmation, :first_name,
                                    :last_name, :mobile_number)
  end
end
