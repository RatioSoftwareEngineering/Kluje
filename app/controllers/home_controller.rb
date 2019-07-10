class HomeController < ApplicationController
  include ApplicationHelper
  include EncryptHelper

  before_action :setup_variables, only: [:index, :contractors_index]

  def error
    response.status = 200
    render 'errors', locals: { error_code: params[:code] }
  end

  def index
    @city = params[:city] && City.find_by_name(params[:city].humanize)

    @hpage = 'homeowners'
    @contractors = Contractor.includes(:skills, account: :country).country(current_country.id).top
    @contractors = @contractors.city(@city.id) if @city
    @contractors = @contractors.limit(9)

    render 'home/index'
  end

  def contractors_index
    @cpage = 'contractors'
    render 'home/contractors_index'
  end

  def about_us
    render 'home/about_us'
  end

  def contact_us
    render 'home/contact_us'
  end

  def locations
    render 'home/locations'
  end

  def sitemap
    respond_to do |format|
      format.xml { render 'home/sitemap_xml', layout: false }
      format.html { render 'home/sitemap' }
    end
  end

  def legal
    @document = LegalDocument.find_by_language_and_slug(locale || session[:locale] || 'en', params[:slug])
    @document ||= LegalDocument.find_by_language_and_slug('en', params[:slug])
    if @document.nil?
      flash[:error] = _('Document not found')
      return redirect_to home_path
    end
    render 'home/legal_document'
  end

  def unsubscribe
    account = Account.find_by_email decryption(params[:token].to_s)
    if account.present?
      account.update(subscribe_newsletter: false)
      return redirect_to home_path, notice: "You have successfully unsubscribed #{account.email} from our mail list"
    end

    redirect_to home_path, alert: 'Invalid token'
  end

  private

  def setup_variables
    @skills = Skill.all
    @availabilities = Residential::Job.availabilities.to_a.map { |i| [i[1], i[0].to_s] }
    @contact_times = Residential::Job.contact_times.to_a.map { |i| [i[1], i[0].to_s] }
    @job_categories = []
    @ratings = Rating.where(
      'approved_at is not null and contractor_id not in (?) and comments != ? and created_at > (?)',
      4, '', Time.zone.today - 3.months
    )
    @posts = Blog.where('is_published = true').order('published_at DESC').limit(3)
  end

  def locale
    if params[:locale] && params[:locale].index('-')
      (params[:locale][0..params[:locale].index('-') - 1]).to_sym
    else
      params[:locale] || I18n.default_locale
    end
  end
end
