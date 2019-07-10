class ApplicationController < ActionController::Base
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, except: :error404

  rescue_from ActionView::MissingTemplate, with: :error404
  rescue_from ActionController::RoutingError, with: :error404

  before_action :set_locale
  before_action :ensure_active
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :prepare_exception_notifier
  before_action :internal_user_check

  after_action :store_location
  # rescue_from CanCan::AccessDenied, with: :access_denied

  def access_denied(exception)
    flash[:error] = exception.message
    redirect_to '/'
  end

  def error404
    respond_to do |format|
      format.html { render template: 'errors/error404', status: 404, layout: 'application' }
      format.all { render nothing: true, status: 404 }
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) ||
      (resource.admin? && '/admin/dashboard') ||
      (session[:previous_url].to_s.include?('ask-an-expert') && session[:previous_url]) ||
      (resource.contractor? && jobs_path(locale: current_locale_country)) ||
      (resource.commercial? && commercial_jobs_path(locale: current_locale_country)) ||
      (resource.agent? && commercial_jobs_path(locale: current_locale_country)) ||
      (resource.homeowner? && jobs_path(locale: current_locale_country)) ||
      home_path
  end

  def authenticate_admin!
    if current_account.try(:admin?)
      true
    else
      flash[:notice] = "You don't have permission to access this page"
      sign_out(current_account) if current_account
      redirect_to new_account_session_path
    end
  end

  def self.default_url_options(options = {})
    options.merge(locale: I18n.locale)
  end

  def after_sign_out_path_for(_resource)
    session[:after_sign_out_url] || home_path
  end

  def store_location # rubocop:disable Metrics/PerceivedComplexity,CyclomaticComplexity
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? &&
                  request.path.exclude?('/accounts/sign_in') &&
                  request.path.exclude?('/accounts/sign_out') &&
                  request.path.exclude?('/contractors/signup') &&
                  request.path.exclude?('/accounts/password/new') &&
                  request.path.exclude?('/accounts/password/edit') &&
                  request.path.exclude?('/accounts/confirmation') &&
                  request.path.exclude?('.js')
    !request.xhr? # don't store ajax calls

    session[:previous_url] = request.fullpath
  end

  def set_admin_locale
    I18n.locale = :en
  end

  protected

  def set_locale
    if params[:locale]
      locale_arr = params[:locale].split('-')
      language = locale_arr[0]
      if I18n.available_locales.include?(language)
        if contain_country_code?
          unless allow_country_code?
            error404 unless Padrino.env == :test || api_controller?
          end
        end

        I18n.locale = language #params[:locale]
      else
        I18n.locale = I18n.default_locale
        # change_locale I18n.locale
        error404 unless Padrino.env == :test || api_controller?
      end
    else
      I18n.locale = I18n.default_locale
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name
  end

  def ensure_active
    return unless signed_in? && current_account.suspended?

    flash[:notice] = _('The account has been suspended')
    sign_out
    redirect_to home_path
  end

  def ensure_signed_in
    return if signed_in?
    flash[:notice] = _('Please log in to continue')
    session[:return_to] = request.url
    redirect_to new_account_session_path
  end

  def prepare_exception_notifier
    request.env['exception_notifier.exception_data'] = {
      current_account: current_account
    }
  end

  def contain_country_code?
    if params[:locale]
      locale_arr = params[:locale].split('-') rescue []
      !locale_arr[1].nil?
    else
      false
    end
  end

  def allow_country_code?
    current_page = "#{params[:controller]}|#{params[:action]}"
    pages_with_country.include?(current_page)
  end

  def require_country_code
    country = locale_country

    error404 unless country
  end

  def locale_country
    country_code = params[:locale].split('-')[1] || ''
    country = Country.available.find_by(cca2: country_code)
  end

  def api_controller?
    self.class < Api::BaseController
  end

  def internal_user_check
    unless Padrino.env == :test || api_controller?
      if contain_country_code?
        country = locale_country
        if internal_user?
          error404 unless current_account.country && country.try(:id) == current_account.try(:country).try(:id)
        end
      end
    end
  end

  # def change_locale locale
  #   return if Padrino.env == :test

  #   query_params = request.query_parameters
  #   session[:locale] = locale
  #   p = { locale: locale }
  #   p.merge!(controller: params[:controller_name]) unless params[:controller_name].blank?
  #   p.merge!(action: action) unless params[:action_name].blank?

  #   url = url_for(p)
  #   url = "#{url}?#{query_params.to_query}" unless query_params.blank?
  #   redirect_to url
  # end
end
