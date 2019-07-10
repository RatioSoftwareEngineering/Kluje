require 'rails_helper'

describe '/api/v1/homeowner/jobs' do
  let(:homeowner) { create :account }
  let(:auth_header) { { 'HTTP_ACCESS_TOKEN' => homeowner.api_key.access_token } }
  let(:job) { create :job, homeowner: homeowner }
  let(:photo1) { Rack::Test::UploadedFile.new("#{Padrino.root}/app/assets/images/logos/dna.png", 'image/png') }
  let(:photo2) { Rack::Test::UploadedFile.new("#{Padrino.root}/app/assets/images/logos/e27.png", 'image/png') }

  describe 'POST /homeowner/jobs/:job_id/photos' do
    it 'uploads photos' do
      params = {
        image1: photo1,
        image2: photo2
      }

      post "/en/api/v1/homeowner/jobs/#{job.id}/photos", params, auth_header

      expect(response.status).to eq 200
      job.reload

      expect(job.photos.length).to eq 2
      expect(job.photos.first[:image_name]).to eq 'dna.png'
      expect(job.photos.second[:image_name]).to eq 'e27.png'

      expect(json.length).to eq 2
      expect(json[0]['id']).to eq job.photos[0].id
      expect(json[1]['id']).to eq job.photos[1].id
      expect(json[0]['job_id']).to eq job.id
    end
  end

  describe 'GET /homeowner/jobs/:job_id/photos' do
    context 'incorrect id' do
      it 'fails with 404' do
        get '/en/api/v1/homeowner/jobs/1/photos', nil, auth_header
        expect(response.status).to eq 404
      end
    end

    it 'retrieves photos' do
      job.photos.create image_name: photo1
      job.photos.create image_name: photo2

      get "/en/api/v1/homeowner/jobs/#{job.id}/photos", nil, auth_header
      expect(response.status).to eq 200

      expect(json.length).to eq 2
      expect(json[0]['id']).to eq job.photos[0].id
      expect(json[1]['id']).to eq job.photos[1].id
      expect(json[0]['job_id'].to_s).to eq job.id.to_s
    end
  end

  describe 'GET /homeowner/jobs/:job_id/photos/:id' do
    context 'incorrect id' do
      it 'fails with 404' do
        get "/en/api/v1/homeowner/jobs/#{job.id + 1}/photos/1", nil, auth_header
        expect(response.status).to eq 404

        photo = job.photos.create image_name: photo1
        get "/en/api/v1/homeowner/jobs/#{job.id}/photos/#{photo.id + 1}", nil, auth_header
        expect(response.status).to eq 404
      end
    end

    it 'retrieves photos' do
      job.photos.create image_name: photo1
      p2 = job.photos.create image_name: photo2

      get "/en/api/v1/homeowner/jobs/#{job.id}/photos/#{p2.id}", nil, auth_header
      expect(response.status).to eq 200

      expect(json['id']).to eq p2.id
      expect(json['job_id'].to_s).to eq job.id.to_s
      expect(json['url'].include?(p2[:image_name])).to be true
    end
  end

  describe 'DELETE /homeowner/jobs/:job_id/photos/:id' do
    context 'incorrect id' do
      it 'fails with 404' do
        delete "/en/api/v1/homeowner/jobs/#{job.id + 1}/photos/1", nil, auth_header
        expect(response.status).to eq 404

        photo = job.photos.create image_name: photo1
        delete "/en/api/v1/homeowner/jobs/#{job.id}/photos/#{photo.id + 1}", nil, auth_header
        expect(response.status).to eq 404
      end
    end

    it 'deletes a photo' do
      p1 = job.photos.create image_name: photo1
      p2 = job.photos.create image_name: photo2

      expect(job.photos.length).to eq 2
      delete "/en/api/v1/homeowner/jobs/#{job.id}/photos/#{p1.id}", nil, auth_header

      expect(response.status).to eq 200
      job.reload
      expect(job.photos.length).to eq 1
      expect(job.photos.first.id).to eq p2.id
    end
  end
end
