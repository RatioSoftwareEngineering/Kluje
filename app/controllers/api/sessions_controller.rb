module Api
  class SessionsController < BaseController
    skip_before_action :authenticate, only: [:create]

    def create
      @account = Account.find_by(email: params[:account][:email])
      if @account.present? && @account.valid_password?(params[:account][:password])
        if @account.deleted? || @account.suspended?
          @account.errors.add(:error, _('The account you are trying to access is no longer active. To reactivate please contact us.'))
          render status: 400, json: @account.errors.as_json
        else
          sign_in(@account, bypass: true)
          if @account.api_key.nil?
            @account.generate_api_key
          end
          @account.add_device params[:account][:platform], params[:account][:device_token]
          @account.reload
          render 'api/v1/accounts/show'
        end
      else
        @errors = {
                   "login" => "Invalid Email or password."
                  }
        render status: 401, json: @errors.as_json
      end
    end

    def destroy
      api_key = ApiKey.find_by_access_token(request.env["HTTP_ACCESS_TOKEN"])
      if api_key
        account = api_key.account
        sign_out
        if params['device_token'].present?
          token = params["device_token"].gsub!(/[<> ]/, '')
          account.devices.where(token: token).delete_all
        end
      end
      render json: {}
    end
  end
end
