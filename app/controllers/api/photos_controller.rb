module Api
  class PhotosController < BaseController
    before_action :set_global_variables

    def create
      if @job.photos.length >= 5
        fail UnprocessableEntity.new("Too many photos (#{@job.photos.length})")
      end

      images = params.select{|k,v| k =~ /image[1-5]{0,1}/}.map{|k,v| v}
      images.each do |image|
        @job.photos.create image_name: image
      end

      @photos = @job.photos
      render 'api/v1/homeowners/jobs/photos'
    end

    def index
      @photos = @job.photos
      render 'api/v1/homeowners/jobs/photos'
    end

    def show
      render 'api/v1/homeowners/jobs/photo'
    end

    def destroy
      @photo.destroy
      render json: {}
    end

    private

    def set_global_variables
      begin
        @job = Residential::Job.find params[:job_id]
        if @job.homeowner != current_account
          fail Forbidden.new("Incorrect job id")
        end
        @photo = @job.photos.find params[:id] if params[:id].present?
      rescue ActiveRecord::RecordNotFound
        fail NotFound.new
      end
    end
  end
end
