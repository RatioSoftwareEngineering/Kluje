# == Schema Information
#
# Table name: revenues
#
#  id         :integer          not null, primary key
#  time       :datetime
#  amount     :float(24)
#  country_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Revenue < ActiveRecord::Base
  belongs_to :country
  before_save :calculate_amount

  scope :latest, -> { order('created_at DESC').limit(1).first }

  def self.refresh(country)
    country.revenues.latest.delete if country.revenues.latest.present?
    time = set_time(country)
    while time < Time.zone.now
      country.revenues.find_or_create_by(time: time)
      time += 1.month
    end
  end

  # rubocop:disable Style/AccessorMethodName
  def self.set_time(country)
    top_ups = Paypal::TopUp.processed.where(currency: country.currency_code.upcase)
    if top_ups.present?
      top_ups.map(&:created_at).compact.min.beginning_of_month
    else
      Time.zone.now.beginning_of_month
    end
  end

  private

  def calculate_amount
    total = @free = @previous_spent = @spent = 0.0
    Account.includes(:contractor).where(country: country, role: 'contractor').find_each do |account|
      set_amounts(account.contractor, time, country.currency_code)
      if (@previous_spent - @free) > 0
        total += @spent
      else
        @spent = @previous_spent + @spent - @free
        total += @spent if @spent > 0
      end
    end
    self.amount = total
  end

  def set_amounts(contractor, time, currency)
    @free = contractor.credits_free(currency)
    @previous_spent = contractor.credits_spent(nil, time, currency)
    @spent = contractor.credits_spent(time, time + 1.month, currency)
  end
end
