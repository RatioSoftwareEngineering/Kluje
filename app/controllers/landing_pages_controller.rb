class LandingPagesController < ApplicationController
  before_action :check_allow_country, only: [:show]

  def show
    @page = LandingPage.find_by(slug: params[:slug], language: params[:locale])
    @page ||= LandingPage.find_by(slug: params[:slug])
    @city = current_city
    if @page.blank?
      flash[:notice] = _('Page not found')
      redirect_to home_path
    else
      respond_to do |format|
        format.rss do
          render 'landing_pages/show', layout: false
        end
        format.html do
          render "landing_pages/show"
        end
      end
    end
  end

  private

  def check_allow_country
    country = locale_country
    if contain_country_code?
      @page = country.get_landing_pages.find_by(slug: params[:slug], language: params[:locale]) if country
      @page ||= country.get_landing_pages.find_by(slug: params[:slug]) if country
    else
      @page = LandingPage.find_by(slug: params[:slug], language: params[:locale])
      @page ||= LandingPage.find_by(slug: params[:slug])
    end

    if session.delete(:redirect_to_target)
      if @page.blank?
        redirect_to home_path
      elsif @page.visible_all_countries? && contain_country_code?
        # redirect_to post_blog_path
        redirect_to @page.landing_page_url(current_locale, current_locale_country)
      end
    else
      if @page.blank? || (@page.visible_all_countries? && contain_country_code?) || (!@page.visible_all_countries? && !contain_country_code?)
        error404
      end
    end
  end
end
