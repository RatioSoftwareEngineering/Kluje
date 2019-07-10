module Api
  class PhoneVerificationsController < BaseController
    skip_before_action :authenticate, only: [:create]

    def create
      verification = PhoneVerification.create(mobile_number: params[:mobile_number],
                                              account: @account, ip: request.ip)
      if verification
        verification.send_verification_code
        case content_type
        when :js, :json then render(json: { success: true })
        else render("contractors/message_confirmation")
        end
      else
        fail UnprocessableEntity.new("Incorrect mobile number")
      end
    end

    def verify
      fail Unauthorized.new unless signed_in?
      fail UnprocessableEntity.new("Missing mobile_number") if params[:mobile_number].blank?
      fail UnprocessableEntity.new("Missing verification_code") if params[:verification_code].blank?

      unless current_account.verify_mobile params[:mobile_number], params[:verification_code]
        fail BadRequest.new('Incorrect phone number or verification code')
      end

      current_account.contractor.approve if current_account.contractor?

      case content_type
      when :js, :json then render json: { mobile_number: current_account.mobile_number }
      else redirect_to notifications_contractors_path(locale: current_locale_country)
      end
    end
  end
end
