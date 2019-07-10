module Api
  class BaseController < ApplicationController
    include ApiExceptions

    layout false

    before_action :authenticate
    skip_before_action :verify_authenticity_token

    rescue_from CanCan::AccessDenied, with: :access_denied
    rescue_from ActiveRecord::RecordNotFound, with: :access_denied
    rescue_from BadRequest, with: :bad_request
    rescue_from Unauthorized, with: :unauthorized
    rescue_from NotFound, with: :not_found
    rescue_from Forbidden, with: :forbidden
    rescue_from UnprocessableEntity, with: :unprocessable_entity

    private

    def authenticate
      if !signed_in?
        @api_key = ApiKey.find_by_access_token(request.env['HTTP_ACCESS_TOKEN'])
        fail Unauthorized.new unless @api_key
        @current_account = @api_key.account
        sign_in(@current_account, bypass: true)
      end
      @account = current_account
      @homeowner = current_account if current_account.homeowner?
      @contractor = current_account.contractor if current_account.contractor?
    end

    [:bad_request, :unauthorized, :unprocessable_entity, :not_found, :forbidden].each do |error|
      define_method(error) do |exception|
        logger.warn "#{error}: msg: #{exception.message}"
        render status: error, json: {error: exception.message}
      end
    end
  end
end
