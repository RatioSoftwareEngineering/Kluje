module ApplicationHelper
  def canonical_url
    return settings.host + '/404' unless controller_name && action_name

    q_params = request.query_parameters
    url = request.url.gsub(/\?.*/, '')

    if q_params.has_key?(:tag) && "blogs".eql?(controller_name) && "show".eql?(action_name)
      url += "/tag/#{q_params["tag"]}"
    end

    # url.gsub!(/en\/?/, '') if controller_name.to_s == 'home' && action_name.to_s == 'index'
    url = url[0..-2] if url[-1] == '/'
    url += "?page=#{params[:page]}/" if params[:page] && params[:page].to_i > 1
    url += '/'
  end

  def localized_url
    return not_found_url unless request.controller && request.action
    Kluje.locales.each { |l| url.gsub!("/#{l}/", "/#{session[:lang]}/") }
    url
  end

  def inline_svg(path)
    path = "app/assets/images/#{path}"
    if File.exist?(path)
      File.open(path, "rb") do |file|
        file.read.html_safe
      end
    else
      ''
    end
  end

  def local_url(lang:)
    path = request.path
    if lang && lang != params[:lang]
      if params[:lang]
        path.gsub!(/\/#{params[:lang]}\//, "/#{lang}/")
      else
        path = "/#{lang}#{path}"
      end
    end
    path
  end

  def localize_select(values)
    values.map { |name, value| [_(name), value] }
  end

  def rating(score)
    result = "<i class='orange fa fa-star-o'></i>"*5
    score.to_i.times { result.sub!('fa-star-o', 'fa-star') }
    result.html_safe
  end

  def faq_item(question, &block)
    @count ||= 1

    answer = capture(&block)

    id = "collapse#{@count+=1}"

    h5 = "<h5 class='color-orange'>#{question}<i class='fa fa-plus pull-right'></i></h5>"
    a = "<a data-parent='#accordion' data-toggle='collapse' href='##{id}'>#{h5}</a>"
    h4 = "<h4 class='panel-title'>#{a}</h4>"
    heading = "<div class='panel-heading'>#{h4}</div>"

    body = "<div class='panel-body'>#{answer}</div>"
    collapse = "<div id='#{id}' class='panel-collapse collapse'>#{body}</div>"

    result = "<div class='panel panel-default'>#{heading}#{collapse}</div>"

    result.html_safe
  end

  def current_country
    @city.try(:country) || current_account.try(:country) || Country.find(retrieve_country_id)
  end

  def location_country
    country = (params[:locale] && Country.find_by(cca2: params[:locale][-2..-1])) || current_country || Country.find_by(name: 'Singapore')
    country.name
  end

  def current_city
    @city || (session[:city_id] && City.find_by(id: session[:city_id])) || current_country.cities.available.first
  end

  def current_locale_country
    I18n.locale.to_s + '-' + current_country.cca2
  end

  def current_locale
    I18n.locale.to_s
  end

  def retrieve_country_id
    return session[:country_id] if session[:country_id]
    country_name = GEO_IP.country(request.ip).country_name
    session[:country_id] = Country.where(name: country_name, available: true).pluck(:id).first
    session[:country_id] ||= Country.where(name: 'Singapore').pluck(:id).first
  end

  def twitterized_type(type)
    case type.to_sym
      when :success
        "alert-success"
      when :notice, :info
        "alert-info"
      when :warning, :warn, :alert
        "alert-warning"
      when :error, :danger
        "alert-danger"
      else
        type.to_s
    end
  end

  def lang_from_browser
    request.env['HTTP_ACCEPT_LANGUAGE'] ||= 'en'
    browser_lang = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z\-A-Z]{2,5}/).first.try(:tr, '-', '_').try(:downcase) || ''
    settings.locales.include?(browser_lang.to_sym) ? browser_lang : 'en'
  end

  def ellipsisize(str, minimum_length=4, edge_length=3)
    return str if str.length < minimum_length or str.length <= edge_length*2
    edge = '.'*edge_length
    mid_length = str.length - edge_length*2
    str.gsub(/(#{edge}).{#{mid_length},}(#{edge})/, '\1...\2')
  end

  def localize_date(date, format = :short)
    return nil if date.nil?
    I18n.localize(date, :format => format)
  end

  def jobs_counter
    jobs_updated_at = Job.maximum(:updated_at)
    Rails.cache.fetch(['jobs_counter', jobs_updated_at]) do
      Job.all.count
    end
  end

  def add_category_param category
    query_params = request.query_parameters
    query_params["category"] = [category.id]

    "#{request.path}?#{query_params.to_query}"
  end

  def question_in_category_url category
    url = questions_path(locale: current_locale_country)
    query_params = { category: [category.id] }

    "#{url}?#{query_params.to_query}"
  end

  def home_path city = nil
    if session[:have_set_country_code]
      city ? index_path(locale: current_locale_country, city: city.slug) : index_path(locale: current_locale_country)
    else
      city ? index_path(city: city.slug) : index_path
    end
  end

  def commercial_home_path
    if session[:have_set_country_code]
      commercial_index_path(locale: current_locale_country)
    else
      commercial_index_path
    end
  end

  def pages_without_country
    %w(homeowners|checklist homeowners|faq homeowners|how_it_works contractors|how_it_works contractors|faq home|about_us home|locations home|contact_us home|sitemap home|legal blogs|show blogs|post)
  end

  def pages_with_country
    %w(
      blogs|post
      landing_pages|show
      contractors|profile contractors|members contractors|ratings contractors|account_details contractors|update_account_details contractors|verification_request contractors|form_verification_request contractors|top_up contractors|billing_history contractors|skills contractors|change_skills contractors|change_password contractors|commercial_request contractors|notifications contractors|locations
      questions|index questions|show questions|me questions|filter questions|new
      jobs|index jobs|create jobs|new jobs|show jobs|edit jobs|update jobs|bid
      commercial/jobs|index commercial/jobs|create commercial/jobs|new commercial/jobs|show commercial/jobs|edit
      home|index commercial/home|index commercial/jobs|bid
      accounts|show
      commercial/accounts|show
      commercial/invoices|index
      answers|me
      commercial/subscriptions|index commercial/subscriptions|invoices commercial/subscriptions|show_invoice
      commercial/meetings|new
      commercial/ratings|new commercial/ratings|create
      ratings|new ratings|create
    )
  end

  def internal_user?
    current_account && (current_account.contractor? || current_account.homeowner? || current_account.agent?)
  end

  def pages_need_redirect
    %w(
      questions|show
      blogs|post
      landing_pages|show
      contractors|profile
    )
  end
end
