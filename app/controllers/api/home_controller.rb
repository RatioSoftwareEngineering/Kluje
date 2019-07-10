module Api
  class HomeController < BaseController
    skip_before_action :authenticate

    def countries
      @countries = Country.available
      render '/api/v1/home/countries'
    end

    def cities
      country = Country.find(params[:id])
      @cities = country.cities.available
      render '/api/v1/home/cities'
    end

    def contractors
      @contractors = Contractor.active
      render '/api/v1/home/contractors'
    end

    def property_types
      @property_types  = Residential::Job.property_types.map { |k, v| { id: k, name: FastGettext._(v) } }
      render json: @property_types.as_json
    end

    def timings
      @timings  = Residential::Job.availabilities.map { |k, v| { id: k, name: v } }
      render json: @timings.as_json
    end

    def skills
      @skills = Skill.all
      render '/api/v1/home/skills'
    end

    def budgets
      country = Country.find_by_id(params[:country_id]) || current_country
      budgets =  Budget.all.map do |budget|
        country_budget = country.budgets.find_by_budget_id(budget.id)
        next unless country_budget
        {
          id: budget.id,
          start_price: country_budget.start_price,
          end_price: country_budget.end_price,
          lead_price: country_budget.lead_price,
          currency: country.currency_code,
          range: country_budget.range
        }
      end
      render json: budgets.as_json
    end

    def contact_times
      @contact_times = Residential::Job.contact_times.map { |k, v| { id: k, name: FastGettext._(v) } }
      render json: @contact_times.as_json
    end

    def ask_an_expert
      @question = Question.new(
        title: 'New Ask an Expert Question',
        body: params[:ask_expert][:question],
        country_id: current_country.try(:id)
      )
      @api_key = ApiKey.find_by_access_token(request.env['HTTP_ACCESS_TOKEN'])
      @question.account_id = @api_key.account_id if @api_key
      # @question.email = params[:ask_expert][:email] || @api_key.account.email
      @question.author = params[:ask_expert][:name] || @api_key.account.full_name

      if @question.save
        @question.deliver
        render json: @question.as_json
      else
        render status: 403, json: @question.errors.as_json
      end
    end
  end
end
