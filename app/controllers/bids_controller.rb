class BidsController < ApplicationController
  def edit
    @bid = Bid.find(params[:id])
  end
  def update
    @bid = Bid.find(params[:id])
    if @bid.update_attributes(bid_params)
      flash[:success] = 'Bid was updated'
    else
      flash[:error] = 'Unable to submit, please try again.'
    end
    redirect_to commercial_job_path(locale: current_locale_country, id: @job.id)
  end

  private
  def bid_params
    params.require(:bid).permit(:amount, :accept)
  end
end