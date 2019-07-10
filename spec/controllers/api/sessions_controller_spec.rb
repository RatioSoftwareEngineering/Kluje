require 'rails_helper'

RSpec.describe Api::SessionsController, type: :api do
  describe 'CREATE - session' do
    let!(:account) { create :account, email: 'test@test.com', password: 'aaa123456' }

    it 'creates session with email and password' do
      account_params = {
        account: {
          email: 'test@test.com',
          password: 'aaa123456'
        }
      }
      post '/en/api/v1/sessions/create', account_params
      response = JSON.parse last_response.body
      expect(response['id']).to eq account.id
      expect(response['email']).to eq account.email
      expect(last_response.status).to eq(200)
    end

    it 'returns 401 with invalid email or password' do
      account_params = {
        account: {
          email: 'test@test.com',
          password: ''
        }
      }
      post '/en/api/v1/sessions/create', account_params

      expect(last_response.status).to eq(401)
    end
  end
end
