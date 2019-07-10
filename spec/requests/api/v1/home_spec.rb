require 'rails_helper'

describe '/api/v1/' do
  describe '/property_types' do
    it 'returns all property types' do
      get '/en/api/v1/property_types'
      expect(response.status).to eq 200
      expect(json.length).to eq 8
      expect(json.map { |e| e['name'] }).to eq Residential::Job.property_types.values
    end
  end

  describe '/timings' do
    it 'returns all timing' do
      get '/en/api/v1/timings'
      expect(response.status).to eq 200
      expect(json.length).to eq 5
      expect(json.map { |e| e['name'] }).to eq ['As soon as possible',
                                                'Within 1 month',
                                                'Within 3 months',
                                                'Within 6 months',
                                                'Above 6 months']
    end
  end

  describe '/contact_times' do
    it 'returns all contact_times' do
      get '/en/api/v1/contact_times'
      expect(response.status).to eq 200
      expect(json.length).to eq 4
      expect(json[0]['name']).to eq 'No preference'
    end
  end

  describe '/skills' do
    it 'returns all skills' do
      get '/en/api/v1/skills'

      expect(response.status).to eq 200
      expect(json.length).to eq Skill.all.length

      skill = Skill.first
      expect(json[0]['id']).to eq skill.id
      expect(json[0]['name']).to eq skill.name

      expect(json[0]['job_categories'].length).to eq skill.job_categories.length

      job_category = skill.job_categories.first
      expect(json[0]['job_categories'][0]['id']).to eq job_category.id
      expect(json[0]['job_categories'][0]['name']).to eq job_category.name
      expect(json[0]['job_categories'][0]['budgets'].length).to eq job_category.budgets.length
      expect(json[0]['job_categories'][0]['budgets']).to eq job_category.budgets.map(&:id)
    end
  end

  describe '/budgets' do
    let!(:country_budgets) do
      singapore = Country.find_by_name 'Singapore'
      Budget.all.map do |budget|
        CountryBudget.find_or_create_by country_id: singapore.id, budget_id: budget.id,
                                        start_price: budget.start_price, end_price: budget.end_price,
                                        lead_price: budget.lead_price
      end
    end

    it 'returns all budgets' do
      get '/en/api/v1/budgets', country_id: Country.find_by(name: 'Singapore').id

      expect(response.status).to eq 200
      expect(json.length).to eq Budget.all.length
      budget = CountryBudget.first
      expect(json[0]['id']).to eq budget.budget_id
      expect(json[0]['start_price']).to eq budget.start_price
      expect(json[0]['end_price']).to eq budget.end_price
      expect(json[0]['lead_price'].to_f).to eq budget.lead_price
      expect(json[0]['range']).to eq budget.range
    end
  end
end
