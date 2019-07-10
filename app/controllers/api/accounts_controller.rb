module Api
  class AccountsController < BaseController
    skip_before_action :authenticate

    def forgot_password
      @account = Account.find_by_email(params[:email])
      @account.send_reset_password_instructions if @account
      render json: { email: params[:email] }
    end
  end
end
