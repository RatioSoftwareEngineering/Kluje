class CountriesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    if params[:commercial] == 'true'
      render '/commercial/countries_table.js', layout: nil
    else
      render '/home/countries_table.js', layout: nil
    end
  end
end
