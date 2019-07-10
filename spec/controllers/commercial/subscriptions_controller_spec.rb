require 'rails_helper'

RSpec.describe Commercial::SubscriptionsController, type: :controller do
  let!(:contractor) { create :contractor }
  let!(:subscription) { create :subscription, contractor: contractor }

  before do
    allow_any_instance_of(ApplicationController).to receive(:ensure_active)
    allow_any_instance_of(ApplicationController).to receive(:prepare_exception_notifier)
    sign_in contractor.account
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, locale: 'en-sg'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #invoices' do
    it 'returns http success' do
      get :invoices, locale: 'en-sg'
      expect(assigns[:subscriptions].first).to eq(subscription)
      expect(response).to have_http_status(:success)
    end
  end
end
