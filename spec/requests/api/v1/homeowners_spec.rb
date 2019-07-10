require 'rails_helper'

describe 'with valid token' do
  let(:homeowner) { create :account }
  let(:auth_header) { { 'HTTP_ACCESS_TOKEN' => homeowner.api_key.access_token } }

  describe 'POST #create' do
    it 'should create new homeowner account' do
      params = { account: { first_name: 'Kyaw Myint', last_name: 'Thein',
                            password: '123123', password_confirmation: '12312',
                            email: 'kyawmyintthein2020@gmail.com' } }
      post '/en/api/v1/homeowner/create', params
      expect(response.status).to eq(200)
      expect(json['first_name']).to eq params[:account][:first_name]
      expect(json['api_key']['access_token']).to eq Account.last.api_key.access_token
    end
  end

  describe 'GET #show' do
    it 'returns the information for one homeowner' do
      get '/en/api/v1/homeowner', nil, auth_header
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #edit' do
    it 'returns the information for one homeowner' do
      get '/en/api/v1/homeowner/edit', nil, auth_header
      expect(response.status).to eq(200)
    end
  end

  describe 'PUT #update' do
    it 'should update homeowner account' do
      params = { account: {
        id: 1, first_name: 'Kyaw Myint', last_name: 'Thein',
        password: '123123', password_confirmation: '12312', email: 'kyawmyintthein2020@gmail.com'
      } }
      put '/en/api/v1/homeowner/update', params, auth_header
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #job/create' do
    it 'should create a job' do
      params = {
        job: {
          availability_id: 1,
          budget_id: 1,
          contact_time_id: 1,
          description: 'Is that it was the best of the day before I get a follow back ',
          job_category_id: 1,
          mobile_number: '98765432',
          postal_code: '123445',
          property_type: 1,
          skill_id: 1,
          city_id: City.first.id
        }
      }
      post '/en/api/v1/homeowner/job/create', params, auth_header
      expect(response.status).to eq 200
      job = Job.last
      expect(job.availability_id).to eq 1
      expect(job.homeowner.mobile_number).to eq '6598765432'
      expect(job.postal_code).to eq '123445'
    end

    it 'should create a job' do
      params = {
        job: {
          availability_id: 1,
          budget_id: 1,
          contact_time_id: 1,
          description: 'Is that it was the best of the day before I get a follow back ',
          job_category_id: 1,
          mobile_number: '48604255255',
          postal_code: '123445',
          property_type: 1,
          skill_id: 1,
          city_id: City.first.id
        }
      }
      post '/en/api/v1/homeowner/job/create', params, auth_header
      expect(response.status).to eq 200
      job = Job.last
      expect(job.availability_id).to eq 1
      expect(job.homeowner.mobile_number).to eq '48604255255'
      expect(job.postal_code).to eq '123445'
    end
  end

  # rubocop:disable Metrics/LineLength
  describe 'POST /api/v1/homeowner/login_with_social' do
    it 'fails when auth token expired' do
      params = {
        auth_token: 'CAADxg1V4Jj4BAApZCjZBAtImbqXn911W3hnMqmNZCbVTN2evLJDqGIhK3Nr2EtH9Nl1zbQ855ZAnPX7wnrdGbv3smbiwC0Mx7sJ92hZBbpnXCNZAVoKLpDFVI3ceQ8lNnGfPlP7l0ZADztBXMmEeQsqRpwGr6hwg42wGffv53bIJtZCh0jueA3wZCYTec9v4227DUZCi3ZCCOs0IzO661VsM2wHgvD0PJ1op8jZAgEf4ya1TZCpZCUtZCr1ppAX',
        email: 'htthach@yahoo.com',
        first_name: 'Hinh',
        last_name: 'Thach',
        platform: 'IOS',
        provider: 'facebook',
        uid: '10152610588667672'
      }
      post '/en/api/v1/homeowner/login_with_social', params

      expect(response.status).to eq 401
      # account = Account.find_by_email(params[:email])
      # expect(json['api_key']['access_token']).to eq account.api_key.access_token
      # expect(json['email']).to eq params[:email]
      # expect(json['provider']).to eq 'facebook'
      # expect(json['uid']).to eq params[:uid]
    end
  end
end
