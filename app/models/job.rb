# == Schema Information
#
# Table name: jobs
#
#  id                        :integer          not null, primary key
#  homeowner_id              :integer
#  contractor_id             :integer
#  job_category_id           :integer
#  skill_id                  :integer
#  work_location_id          :integer
#  budget_id                 :integer
#  description               :text(65535)      not null
#  availability_id           :integer
#  postal_code               :string(255)
#  lat                       :decimal(15, 10)
#  lng                       :decimal(15, 10)
#  state                     :string(255)      default("pending")
#  purchased_at              :datetime
#  approved_at               :datetime
#  deleted_at                :datetime
#  created_at                :datetime
#  updated_at                :datetime
#  contact_time_id           :integer          default(0), not null
#  archived_at               :datetime
#  property_type             :integer
#  code                      :string(255)
#  image                     :string(255)
#  priority_level            :integer
#  specific_contractor_id    :integer
#  require_renovation_loan   :boolean
#  ref_code                  :string(255)
#  city_id                   :integer
#  client_type               :string(255)
#  renovation_type           :integer
#  floor_size                :integer
#  client_type_code          :string(255)
#  concierge_service         :boolean          default(TRUE)
#  address                   :string(255)
#  budget_value              :decimal(30, 10)
#  type                      :string(255)      default("Residential::Job")
#  start_date                :datetime
#  commission_rate           :integer          default(10), not null
#  concierges_service_amount :decimal(10, )    default(20)
#  number_of_quote           :integer          default(0)
#  client_first_name         :string(150)
#  client_last_name          :string(150)
#  client_email              :string(255)
#  client_mobile_number      :string(20)
#  partner_code              :string(255)
#  partner_id                :integer
#
# Indexes
#
#  index_jobs_on_state  (state)
#

class Job < ActiveRecord::Base
  acts_as_paranoid

  #  belongs_to :budget
  belongs_to :contractor, class_name: 'Contractor'
  belongs_to :homeowner, class_name: 'Account'
  belongs_to :job_category
  belongs_to :skill
  belongs_to :city

  has_many :bids
  has_one :invoice
  has_many :job_views
  has_many :photos
  has_many :clarifications
  has_many :ratings
  has_many :meetings
  has_many :repost_jobs

  delegate :country, to: :city

  # Validations
  validates :description, length: { minimum: 30 }
  validates :property_type, presence: true

  # Callbacks
  before_save :fetch_coordinates
  before_save :generate_code
  after_create :approve_if_email_verified

  # Scopes
  scope :approved, -> { where('approved_at IS NOT NULL') }
  scope :archived, -> { where('archived_at IS NOT NULL') }
  scope :not_approved, -> { where('approved_at IS NULL') }
  scope :not_archived, -> { where('archived_at IS NULL') }
  scope :purchased, -> { where('purchased_at IS NOT NULL AND contractor_id IS NOT NULL') }
  scope :commercial, -> { where("type = 'Commercial::Job'") }
  scope :residential, -> { where("type = 'Residential::Job'") }

  MAXIMUM_BID_COUNT = 3

  state_machine initial: :pending do
    # Events
    event :approve do
      transition pending: :approved
    end

    event :complete do
      transition [:pending, :approved, :bidded, :purchased] => :complete
    end

    event :send_for_moderation do
      transition [:approved, :pending] => :pending, :unless => [:is_purchased?, :has_bids?]
    end

    event :accept_bid do
      transition [:approved, :bidded] => :bidded, :unless => [:is_purchased?, :maximum_no_of_bids_reached?]
    end

    event :purchase do
      transition bidded: :purchased, if: :has_bids?
    end

    event :archive do
      transition any => :archived
    end

    event :unarchive do
      transition archived: :purchased, if: :is_purchased?
      transition archived: :bidded, if: :has_bids?, unless: :is_purchased?
      transition archived: :approved, unless: [:is_purchased?, :has_bids?]
    end

    # Transitions
    before_transition approved: :pending do |job|
      job.approved_at = nil
    end

    before_transition pending: :approved do |job|
      job.touch(:approved_at)
    end

    before_transition [:approved, :bidded] => :bidded do |job, transition|
      job.bids.create(contractor: transition.args.first, amount: job.lead_price, currency: job.country.currency_code)
      unless job.homeowner.nil?
        if job.commercial?
          job.notify_homeowner_commercial_job_bided transition.args.first
        else
          job.notify_homeowner_job_purchased transition.args.first
        end
      end
    end

    before_transition bidded: :purchased do |job, transition|
      job.touch(:purchased_at)
      job.contractor = transition.args.first
    end

    before_transition any => :archived do |job, _transition|
      job.touch(:archived_at)
    end

    after_transition pending: :approved do |job|
      if job.type == 'Commercial::Job'
        job.notify_contractors_commercial_job_post
        job.notify_homeowner
      end
    end
  end

  def approve_if_email_verified
    approve if homeowner.try(:email_verified?) && !commission?
  end

  def budget
    CountryBudget.find_by_budget_id_and_country_id(budget_id, country.id)
  end

  def commission?
    false # budget_id >= 21 && country.name == 'Singapore'
  end

  def residential?
    false
  end

  def commercial?
    false
  end

  def lead_price(contractor = nil)
    if contractor && bid = contractor.bids.where(job_id: id).first
      return bid.amount
    end
    budget.try(:lead_price) || 0.0
  end

  def lead_price_formatted(contractor = nil)
    country.price_format % lead_price(contractor)
  end

  def notify_contractors
  end

  def notify_homeowner
    #    Resque.enqueue(Mail,self)
    notify_homeowner_job_approved if homeowner
  end

  def send_sms_for_suitable_job_post(_premium)
    msg = "Reply: #{code} to bid lead. #{job_category.name[0..29]} / #{availability[7..14]} / Bud:#{budget.range} / Bid:$ #{lead_price_formatted} / #{description[0..49]}"

    @contractors = suitable_contractors.where(mobile_alerts: true)
    # Remove premium membership
    # @contractors = @contractors.select{ |c| c.premium? == premium }
    # @contractors = @contractors.select{ |c| c.commercial? } if self.is_a?(Commercial::Job)

    @contractors.each do |contractor|
      account = contractor.account
      if contractor.update_sms_count && account.mobile_number
        account.sms(priority_level ? "** #{msg}" : msg)
      end
    end
  end

  def self.availabilities
    {
      8 => _('As soon as possible'),
      3 => _('Within 1 month'),
      5 => _('Within 3 months'),
      6 => _('Within 6 months'),
      7 => _('Above 6 months')
    }
  end

  def availability
    self.class.availabilities[availability_id]
  end

  def property_type_name
    self.class.property_types[property_type]
  end

  def self.contact_times
    {
      0 => _('No preference'),
      1 => _('Morning (8am - 12pm)'),
      2 => _('Afternoon (12pm - 6pm)'),
      3 => _('Evening (6pm - 9pm)')
    }
  end

  def self.property_types
    {
      3 => _('Apartment/Flat'),
      6 => _('Condo'),
      9 => _('Terraced'),
      10 => _('Semi Detached'),
      13 => _('Detached'),
      11 => _('Bungalow'),
      12 => _('Townhouse'),
      8 => _('Commercial')
    }
  end

  def renovation_type_name
    self.class.renovation_types[renovation_type]
  end

  def self.renovation_types
    {
      1 => _('Space Planning'),
      2 => _('Interior Designer'),
      3 => _('Minor Renovation'),
      5 => _('Whole Renovation'),
      6 => _('Renovation Excluding Furniture'),
      7 => _('Renovation Including Furniture'),
      8 => _('Reinstatement of Space'),
      9 => _('Security Solutions')
    }
  end

  def floor_size_name
    self.class.floor_sizes[floor_size]
  end

  def self.floor_sizes
    {
      1 => _('Below 1,000 Sq Feet'),
      2 => _('1,001 - 2,001 Sq Feet'),
      3 => _('2,001 - 3,001 Sq Feet'),
      5 => _('3,001 - 4,001 SqFeet'),
      6 => _('4,001 - 5,001 SqFeet'),
      7 => _('6,001 - 7,001 SqFeet'),
      8 => _('7,001 - 8,001 SqFeet'),
      9 => _('Above 8,001 SqFeet')
    }
  end

  def contact_time
    self.class.contact_times[contact_time_id]
  end

  def is_approved?
    approved_at.present? && state != 'pending'
  end

  def is_purchased?
    contractor.present? && purchased_at.present?
  end

  def is_bidded?
    !bids.empty?
  end

  def is_not_bidded?
    bids.empty?
  end

  def is_archived?
    archived_at.present? && state == 'archived'
  end

  def is_expired?
    Time.now > expires_at
  end

  def is_eligible_for_review?(contractor_id)
    # Here we allow homeowners to leave ratings not just for contractor whom purchased the job
    bids.pluck(:contractor_id).include?(contractor_id) && !ratings.pluck(:contractor_id).include?(contractor_id)
  end

  def has_invoices?
    invoice.present?
  end

  def has_bids?
    !bids.empty?
  end

  def has_meeting?
    !meetings.empty?
  end

  def has_clatification?
    !clarifications.empty?
  end

  def premium_only?
    approved_at && approved_at > Time.now - 3.hours
  end

  def total_views
    job_views.count
  end

  def maximum_no_of_bids_reached?
    bids.count >= MAXIMUM_BID_COUNT
  end

  def suitable_contractors
    if !specific_contractor_id.nil?
      Contractor.active.city(city_id).where(id: specific_contractor_id)
    else
      Contractor.active.city(city_id).joins(:contractor_skills).where('skill_id = ?', skill_id)
    end
  end

  def notify_contractors_suitable_job(_premium)
    # TODO
    # This needs to be send to a jobs que to process
    @contractors = suitable_contractors.where(email_alerts: true)
    # Remove premium membership
    # @contractors = @contractors.select{ |c| c.premium? == premium }

    @contractors.each do |contractor|
      JobMailer.notify_contractor_suitable_job(contractor, self).deliver
    end
  end

  def notify_homeowner_job_purchased(bid_contractor)
    JobMailer.notify_homeowner_job_purchased(homeowner, bid_contractor, self).deliver_now
    homeowner.notify "Your job has been purchased by #{bid_contractor.company_name}"
  end

  def notify_homeowner_job_approved
    JobMailer.notify_homeowner_job_approved(homeowner, self).deliver
    homeowner.notify 'Your job is approved'
  end

  def thank_homeowner_for_posting_a_job
    JobMailer.thank_homeowner_for_posting_a_job(homeowner, self).deliver
  end

  def job_expires_at
    unless approved_at.nil?
      case availability_id
      when 1
        14.days
      when 2
        14.days
      when 3
        30.days
      when 4
        60.days
      end
    end
  end

  def location
    if postal_code.present?
      "#{postal_code} #{city.name}"
    else
      city.name
    end
  end

  private

  def fetch_coordinates
    if postal_code_changed? || lat.blank? || lng.blank?
      results = Geocoder.search("#{city.country.name}, #{city.name}, #{postal_code}")
      if results[0]
        self.lat = results[0].latitude
        self.lng = results[0].longitude
      else
        Rails.logger.info "#{city.country.name}, #{city.name}, #{postal_code}"
        Rails.logger.info results.inspect
      end
    end
  end

  def generate_code
    self.code = rand.to_s[2..7] if code.nil?
  end

  def expires_at
    created_at + case availability_id
                 when 1
                   7.days
                 when 2
                   14.days
                 when 3
                   30.days
                 else
                   60.days
                      end
  end
end
