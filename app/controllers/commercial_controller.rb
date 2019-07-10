class CommercialController < ApplicationController
  layout 'commercial'

  before_action :redirect_if_country_not_commercial
  before_action :redirect_if_city_not_commercial
  before_action :redirect_if_contractor_not_commercial
  before_action :redirect_if_contractor_is_commercial

  private

  def redirect_if_country_not_commercial
    unless current_country.commercial?
      flash[:notice] = 'Kluje Commercial has not launched in %{country} yet. Stay tuned!' % { country: current_country.name }
      redirect_to home_path
    end
  end

  def redirect_if_city_not_commercial
    unless current_city.commercial?
      flash[:notice] = 'Kluje Commercial has not launched in %{city} yet. Stay tuned!' % { city: current_city.name }
      redirect_to home_path
    end
  end

  def redirect_if_contractor_not_commercial
    if current_account && current_account.contractor?
      unless current_account.contractor.commercial?
        flash[:notice] = "Your contractor account doesn't accept to access to Kluje Commercial"
        redirect_to home_path
      end
    end
  end

  def redirect_if_contractor_is_commercial
    if current_account && current_account.contractor?
      if current_account.contractor.commercial?
        if current_account.contractor.accept_agreement.blank? || current_account.contractor.accept_agreement == 0
          render 'commercial/contractors/accept_agreement'
        end
      end
    end
  end
end
