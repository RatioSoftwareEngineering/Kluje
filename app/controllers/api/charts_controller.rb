module Api
  class ChartsController < BaseController
    # skip_before_action :authenticate
    before_action :check_range, only: [
      :residential_jobs, :commercial_jobs,
      :contractor_sign_up, :commercial_contractor_sign_up,
      :bids
    ]

    before_action :check_country, only: [:bids_history, :revenue, :top_up_history]

    def residential_jobs # rubocop:disable Metrics/AbcSize
      time_period = 12.send(range.to_s.pluralize)
      start_time = (Time.zone.now - time_period).send("beginning_of_#{range}")
      time = start_time
      all = Residential::Job.where('created_at > ?', start_time)
      categories = [[:small, 1, 4], [:medium, 5, 14], [:large, 15, 27], [:total, 1, 27]]
      jobs = { 'date' => categories.map { |c| c.first.to_s.titleize } }
      while time < Time.zone.now
        jobs[time.strftime(date_format[range])] ||= [0, 0, 0, 0]
        time += 1.send(range)
      end
      categories.each.with_index do |details, i|
        _size, start_id, end_id = details
        group = all.where('budget_id >= ? AND budget_id <= ?', start_id, end_id)
        group = group.group_by do |b|
          b.created_at.send("beginning_of_#{range}").strftime(date_format[range])
        end

        group.each do |date, value|
          jobs[date] ||= [0, 0, 0, 0]
          jobs[date][i] = value.length
        end
      end
      jobs = jobs.map { |k, v| [k, v].flatten }

      render json: jobs
    end

    def commercial_jobs # rubocop:disable Metrics/AbcSize
      time_period = 12.send(range.to_s.pluralize)
      start_time = (Time.zone.now - time_period).send("beginning_of_#{range}")
      time = start_time
      all = Commercial::Job.where('created_at > ?', start_time)
      categories = [[:total, nil, nil]]
      jobs = { 'date' => categories.map { |c| c.first.to_s.titleize } }

      while time < Time.zone.now
        jobs[time.strftime(date_format[range])] ||= [0]
        time += 1.send(range)
      end

      categories.each.with_index do |_details, i|
        group = all
        group = group.group_by do |b|
          b.created_at.send("beginning_of_#{range}").strftime(date_format[range])
        end

        group.each do |date, value|
          jobs[date] ||= [0]
          jobs[date][i] = value.length
        end
      end
      jobs = jobs.map { |k, v| [k, v].flatten }

      render json: jobs
    end

    def contractor_sign_up # rubocop:disable Metrics/AbcSize
      time_period = 12.send(range.to_s.pluralize)
      start_time = (Time.zone.now - time_period).send("beginning_of_#{range}")
      time = start_time
      all = Contractor.where('created_at > ?', start_time)
      categories = [[:total, nil, nil]]
      contractors = { 'date' => categories.map { |c| c.first.to_s.titleize } }

      while time < Time.zone.now
        contractors[time.strftime(date_format[range])] ||= [0]
        time += 1.send(range)
      end

      categories.each.with_index do |_details, i|
        group = all

        group = group.group_by do|b|
          b.created_at.send("beginning_of_#{range}").strftime(date_format[range])
        end

        group.each do |date, value|
          contractors[date] ||= [0]
          contractors[date][i] = value.length
        end
      end

      contractors = contractors.map { |k, v| [k, v].flatten }

      render json: contractors
    end

    def commercial_contractor_sign_up # rubocop:disable Metrics/AbcSize
      time_period = 12.send(range.to_s.pluralize)
      start_time = (Time.zone.now - time_period).send("beginning_of_#{range}")
      time = start_time
      all = Contractor.where('commercial_registration_date > ?', start_time)
      categories = [[:total, nil, nil]]
      contractors = { 'date' => categories.map { |c| c.first.to_s.titleize } }

      while time < Time.zone.now
        contractors[time.strftime(date_format[range])] ||= [0]
        time += 1.send(range)
      end

      categories.each.with_index do |_details, i|
        group = all
        group = group.group_by do|b|
          b.commercial_registration_date.send("beginning_of_#{range}").strftime(date_format[range])
        end

        group.each do |date, value|
          contractors[date] ||= [0]
          contractors[date][i] = value.length
        end
      end

      contractors = contractors.map { |k, v| [k, v].flatten }

      render json: contractors
    end

    def bids # rubocop:disable Metrics/AbcSize
      time_period = 12.send(range.to_s.pluralize)
      start_time = (Time.zone.now - time_period).send("beginning_of_#{range}")
      time = start_time
      all = Bid.joins(:job).where('bids.created_at > ?', start_time)
      categories = [[:small, 1, 4], [:medium, 5, 14], [:large, 15, 27], [:total, 1, 27]]
      bids = { 'date' => categories.map { |c| c.first.to_s.titleize } }
      while time < Time.zone.now
        bids[time.strftime(date_format[range])] ||= [0, 0, 0, 0]
        time += 1.send(range)
      end

      categories.each.with_index do |details, i|
        _size, start_id, end_id = details
        group = all.where('jobs.budget_id >= ? AND jobs.budget_id <= ?', start_id, end_id)
        group = group.group_by do |b|
          b.created_at.send("beginning_of_#{range}").strftime(date_format[range])
        end

        group.each do |date, value|
          bids[date] ||= [0, 0, 0, 0]
          bids[date][i] = value.length
        end
      end

      bids = bids.map { |k, v| [k, v].flatten }

      render json: bids
    end

    def bids_history
      country = Country.find params[:country_id]
      currency = country.currency_code.upcase
      bids = Bid.where(currency: currency)
      if bids.present?
        time = bids.map(&:created_at).compact.min.beginning_of_month
      else
        time = Time.zone.now.beginning_of_month
      end
      values = [['Date', currency]]

      while time < Time.zone.now
        value = bids.where('created_at >= ? AND created_at < ?', time, time + 1.month).sum(:amount)
        values << [time.strftime('%b \'%y'), value.to_i]
        time += 1.month
      end

      render json: values
    end

    def revenue
      currency = country.currency_code.upcase
      top_ups = Paypal::TopUp.processed.where(currency: currency)
      if top_ups.present?
        time = top_ups.map(&:created_at).compact.min.beginning_of_month
      else
        time = Time.zone.now.beginning_of_month
      end
      values = [['Date', currency]]
      while time < Time.zone.now
        revenue = Revenue.find_by(time: time, country: country)
        values << [time.strftime('%b \'%y'), revenue.amount] if revenue
        time += 1.month
      end

      render json: values
    end

    def top_up_history
      currency = country.currency_code.upcase
      top_ups = Paypal::TopUp.processed.where(currency: currency)
      if top_ups.present?
        time = top_ups.map(&:created_at).compact.min.beginning_of_month
      else
        time = Time.zone.now.beginning_of_month
      end
      values = [['Date', currency]]
      while time < Time.zone.now
        value = top_ups.where('created_at >= ? AND created_at < ?', time, time + 1.month).sum(:amount)
        values << [time.strftime('%b \'%y'), value.to_i]
        time += 1.month
      end

      render json: values
    end

    private

    def valid_range
      [:day, :week, :month]
    end

    def date_format
      { day: '%d %b', week: '%d %b', month: '%b \'%y' }
    end

    def range
      params[:range].to_sym
    end

    def check_range
      return render json: {} unless valid_range.include?(range)
    end

    def country
      Country.find params[:country_id].to_i
    end

    def check_country
      return render json: {} if country.nil?
    end
  end
end
