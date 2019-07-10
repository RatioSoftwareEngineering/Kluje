require 'rails_helper'

RSpec.describe ContractorsController, type: :controller do
  let!(:country) { create :country }

  before do
    allow_any_instance_of(ApplicationController).to receive(:ensure_active)
    allow_any_instance_of(ApplicationController).to receive(:prepare_exception_notifier)
  end

  describe 'GET #new' do
    it 'returns instance variables' do
      get :new, locale: "en-#{country.cca2}"
      expect(assigns[:account]).to be_a(Account)
      expect(assigns[:account].contractor).to be_a(Contractor)
      expect(assigns[:skills]).to be_a(Array)
    end
  end

  describe 'POST #create' do
    it 'retuens http success for signing up contractor' do
      params = {
        locale: "en-#{country.cca2}",
        account: {
          country_id: country.id, first_name: 'name', last_name: 'NAME',
          contractor_attributes: {
            company_name: 'company name'
          },
          email: 'email@email.com', password: '1234567'
        }
      }
      post :create, params
      expect(response).to have_http_status(:success)
      expect(assigns[:account].first_name).to eq 'name'
      expect(assigns[:account].contractor.company_name).to eq 'company name'
    end
  end
end
