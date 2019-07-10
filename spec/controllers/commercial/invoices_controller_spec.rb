require 'rails_helper'
include Devise::TestHelpers

RSpec.describe Commercial::InvoicesController, type: :controller do
  let(:client) { create :account }
  let!(:commercial_job) { create :commercial_job, homeowner: client, state: 'complete' }
  let!(:regidential_job) { create :job, homeowner: client, state: 'complete' }
  let!(:client_invoice) { create :invoice, recipient: client, job: commercial_job }

  let!(:contractor) { create :contractor }
  let(:contractor_account) { create :account, role: 'contractor', contractor: contractor }
  let!(:contractor_invoice) { create :invoice, sender: contractor, job: commercial_job }

  describe 'GET #index' do
    it 'returns http success when login as client' do
      sign_in client
      get :index, locale: 'en-sg'
      expect(assigns[:invoices]).to include(client_invoice)
      expect(assigns[:invoices]).not_to include(contractor_invoice)
      expect(assigns[:jobs]).to include(commercial_job)
      expect(assigns[:jobs]).not_to include(regidential_job)
      expect(response).to have_http_status(:success)
    end

    it 'returns http success when login as contractor' do
      sign_in contractor_account
      get :index, locale: 'en-sg'
      expect(assigns[:invoices]).to include(contractor_invoice)
      expect(assigns[:invoices]).not_to include(client_invoice)
      expect(response).to have_http_status(:success)
    end
  end
end
