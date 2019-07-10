class SessionsController < ApplicationController
  def change_locale
    query = params[:query] || URI.parse(request.referer).query || ''
    p = URI.decode_www_form(query).to_h.with_indifferent_access.delete_if { |_k, v| v.empty? }

    if internal_user?
      session[:country_id] = p[:country_id] =  current_account.try(:country).try(:id).to_s rescue ''
    else
      session[:country_id] = p[:country_id] = params[:country_id]
    end

    session[:locale] = params[:new_locale]
    session[:city_id] = params[:city_id]
    
    # p[:city] = City.find(params[:city_id]).name.parameterize.underscore
    current_page = "#{params[:controller_name]}|#{params[:action_name]}"
    pages = pages_with_country
    p[:locale] = params[:new_locale]
    if pages.include?(current_page)
      p[:locale] = params[:new_locale] + '-' + Country.find(session[:country_id]).cca2
    else
      p[:locale] = params[:new_locale]
    end

    session[:have_set_country_code] = true

    url = url_for(p.merge(controller: params[:controller_name], action: params[:action_name]))

    if pages_need_redirect.include?(current_page)
      session[:redirect_to_target] = true
    else
      session.delete(:redirect_to_target)
    end

    redirect_to url[0..(url.index('?') - 1)]
  end

  def destroy
    sign_out
    session.delete(:return_to)
    session.delete(:have_set_country_code)
    session.delete(:redirect_to_target)

    redirect_to home_path
  end

  def auth_callback # rubocop:disable Metrics/AbcSize,  Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    auth = request.env['omniauth.auth']
    redirect_to new_account_session_path unless auth['provider'] && auth['uid']

    confirmed_at = (auth['info']['verified'] || auth['extra']['raw_info']['email_verified'] == 'true') && Time.zone.now

    data = {
      first_name: auth['info']['first_name'] || auth['info']['name'],
      last_name: auth['info']['last_name'] || auth['info']['name'],
      email: auth['info']['email'],
      confirmed_at: confirmed_at,
      provider: auth['provider'],
      uid: auth['uid']
    }

    @account = Account.find_by_provider_and_uid(
      data[:provider],
      data[:uid]
    ) if data[:provider].present? && data[:uid].present?

    @account ||= Account.find_by_email(data['email']) if data[:email].present?

    unless @account
      @account = Account.new data.merge(role: 'homeowner')
      flash[:warning] = _('Please update your mobile number and country information')
      unless @account.save
        flash[:error] = @account.errors.full_messages.to_sentence
        return redirect_to new_account_session_path
      end
    end

    data.each { |k, v| @account.update_attribute(k, v) if @account[k].blank? }

    sign_in(@account, bypass: true)
    redirect_to jobs_path(locale: current_locale_country)
  end

  def auth_failure
    flash[:error] = params[:message].humanize
    redirect_to new_account_session_path
  end
end
