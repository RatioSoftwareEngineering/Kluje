module Api
  class RatingsController < BaseController
    def create
      begin
        @job = Residential::Job.find(params[:rating][:job_id])
        @contractor = Contractor.find(params[:rating][:contractor_id])
      rescue ActiveRecord::RecordNotFound
        fail NotFound.new("Job not found") unless @job
        fail NotFound.new("Contractor not found")
      end
      if @job.is_eligible_for_review?(@contractor.id)
        @job.ratings.create(rating_params)
        @job.purchase(@contractor)
        @rating = @job.ratings.last
        @job.contractor.account.notify "Yay! You've received a rating from homeowner. Job #{@job.id}"
      else
        fail BadRequest.new
      end
      render '/api/v1/ratings/create'
    end

    def show
      @rating = Rating.find(params[:id])
      render json: @rating.as_json
    end

    private

    def rating_params
      params.require(:rating).permit(:contractor_id, :professionalism, :quality, :value, :comments, :score, :approved_at)
    end
  end
end
