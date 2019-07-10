require 'rails_helper'

describe '/en/api/v1/ratings' do
  let(:homeowner) { create :account }
  let(:auth_header) { { 'HTTP_ACCESS_TOKEN' => homeowner.api_key.access_token } }
  let(:job) { create :job, homeowner: homeowner }
  let(:contractor) { create :contractor }

  describe 'POST /ratings/create' do
    it 'creates a rating' do
      job.accept_bid contractor
      params = {
        rating: {
          comments: 'The fact I can get it right away with',
          contractor_id: contractor.id,
          job_id: job.id,
          professionalism: 3,
          quality: 2,
          value: 1
        }
      }
      post '/en/api/v1/ratings', params, auth_header
      expect(response.status).to eq 200
      expect(contractor.ratings.length).to eq 1
      rating = contractor.ratings.last
      expect(rating.professionalism).to eq params[:rating][:professionalism]
      expect(rating.quality).to eq params[:rating][:quality]
      expect(rating.value).to eq params[:rating][:value]
    end
  end
end
