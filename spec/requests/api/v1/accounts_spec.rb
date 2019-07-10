require 'rails_helper'

describe '/api/v1/accounts_controller' do
  let(:homeowner) { create :account }

  describe 'POST /api/v1/accounts/password/forgot' do
    it 'should generate the reset password token' do
      post '/en/api/v1/accounts/password/forgot', email: homeowner.email
      expect(response.status).to eq(200)
      expect(json['email']).to eq homeowner.email
      homeowner.reload
      expect(homeowner.reset_password_token).to_not be_nil
      expect(homeowner.reset_password_token).to_not eq ''
    end
  end
end
