require 'rails_helper'

describe '/api/v1/contractors' do
  let(:country) { create :country }
  let(:account) { create :contractor_account, country: country }
  let(:city) { create :city, country: country }
  let(:auth_header) { { 'HTTP_ACCESS_TOKEN' => account.api_key.access_token } }

  describe 'GET /api/v1/contractor/credit' do
    it 'should return credit balance' do
      get '/en/api/v1/contractor/credit', nil, auth_header
      expect(response.status).to eq(200)
      expect(json['credit_balance']).to eq account.contractor.credits_balance
    end
  end

  describe 'POST /api/v1/contractors/create' do
    it 'should create a contractor' do
      params = {
        account: {
          contractor: {
            skills: 1,
            uen_number: '22828649X',
            company_name: 'Maciejs test company'
          },
          email: 'contractor+test@kluje.com',
          first_name: 'Maciej',
          last_name: 'Kruk',
          password: 'secretpassword1234',
          mobile_number: '6580120123',
          country_id: country.id
        }
      }
      post '/en/api/v1/contractors/create', params
      expect(response.status).to eq(200)
      account = Account.find_by_email params[:account][:email]
      expect(account.first_name).to eq params[:account][:first_name]
      expect(account.last_name).to eq params[:account][:last_name]
      expect(account.contractor.uen_number).to eq params[:account][:contractor][:uen_number]
      expect(account.contractor.company_name).to eq params[:account][:contractor][:company_name]
      expect(account.contractor.skills).to eq [Skill.find(1)]
      expect(account.mobile_number).to be nil
    end

    it 'should create a contractor' do
      verification = create :phone_verification, mobile_number: '6580120123'
      params = {
        account: {
          contractor: {
            skills: 1,
            uen_number: '22828649X',
            company_name: 'Maciejs test company'
          },
          email: 'contractor+test@kluje.com',
          first_name: 'Maciej',
          last_name: 'Kruk',
          password: 'secretpassword1234',
          mobile_number: '6580120123',
          verification_code: verification.verification_code,
          country_id: country.id
        }
      }
      post '/en/api/v1/contractors/create', params
      expect(response.status).to eq(200)
      account = Account.find_by_email params[:account][:email]
      expect(account.first_name).to eq params[:account][:first_name]
      expect(account.last_name).to eq params[:account][:last_name]
      expect(account.contractor.uen_number).to eq params[:account][:contractor][:uen_number]
      expect(account.contractor.company_name).to eq params[:account][:contractor][:company_name]
      expect(account.contractor.skills).to eq [Skill.find(1)]
      expect(account.mobile_number).to eq '6580120123'
    end
  end

  describe 'jobs' do
    let!(:job1) { create :job, skill_id: 1, city: city, approved_at: Time.zone.now - 5.hours }
    let!(:job2) { create :job, skill_id: 2, city: city, approved_at: Time.zone.now - 5.hours }
    let!(:job3) { create :job, skill_id: 3, city: city, approved_at: Time.zone.now - 5.hours }

    describe 'GET /api/v1/contractor/jobs' do
      it 'should retrieve a list of jobs' do
        get '/en/api/v1/contractor/jobs', nil, auth_header
        expect(response.status).to eq 200
        expect(json.length).to eq 2
        expect(json[0]['id']).to eq job1.id
        expect(json[1]['id']).to eq job2.id
      end
    end

    describe 'POST /api/v1/contractor/jobs/bid' do
      it 'should create a bid' do
        post '/en/api/v1/contractor/jobs/bid', { id: job1.id }, auth_header
        expect(response.status).to eq 200
        [:id, :skill_id, :budget_id, :postal_code].each do |attr|
          expect(json[attr.to_s]).to eq job1.send(attr)
        end
        [:first_name, :last_name, :email, :mobile_number].each do |attr|
          expect(json['account'][attr.to_s]).to eq job1.homeowner.send(attr).to_s
        end
      end
    end
  end
end
