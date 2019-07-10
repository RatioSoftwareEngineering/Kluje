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

class Commercial::Job < Job
  has_many :meetings
  belongs_to :partner, class_name: 'Account'

  validates :concierge_service, inclusion: { in: [true, false] }
  validates :number_of_quote, presence: true
  validates :renovation_type, presence: true
  validates :budget_value, presence: true
  validates :start_date, presence: true
  validates :address, presence: true
  validates :floor_size, presence: true
  validate :partner_code_validation, if: proc { |job| job.partner_code.present? }
  validate :client_mobile_number_validation, if: '@client_mobile'

  before_create :set_partner
  before_validation :normalize_mobile_number, if: 'self.client_mobile_number.present?'

  scope :state_jobs, ->(state) { where(state == 'all' ? "state != 'archived'" : "state = '#{state}'") }

  def budget
    Commercial::Budget.new(budget_value, city.country)
  end

  def self.property_types
    {
      1 => _('Office'),
      2 => _('Food and Beverage'),
      3 => _('Retail')
    }
  end

  def self.renovation_types
    {
      1 => _('Space Planning'),
      2 => _('Interior Design'),
      3 => _('Minor Renovation'),
      5 => _('Whole Renovation'),
      6 => _('Renovation Excluding Furniture'),
      7 => _('Renovation Including Furniture'),
      8 => _('Reinstatement of Space'),
      9 => _('Security Solutions')
    }
  end

  def self.floor_sizes
    {
      1 => _('Below 1,000 Sq Feet'),
      2 => _('1,001 - 2,001 Sq Feet'),
      3 => _('2,001 - 3,001 Sq Feet'),
      5 => _('3,001 - 4,001 Sq Feet'),
      6 => _('4,001 - 5,001 Sq Feet'),
      7 => _('6,001 - 7,001 Sq Feet'),
      8 => _('7,001 - 8,001 Sq Feet'),
      9 => _('Above 8,001 Sq Feet')
    }
  end

  def commercial?
    true
  end

  def partner_code_validation
    partner = Account.find_by(agent: true, partner_code: partner_code)
    if partner.present?
      self.partner_id = partner.id
    else
      errors.add(:partner_code, 'is invalid')
    end
  end

  def notify_contractors_commercial_job_post
    # TODO
    # This needs to be send to a jobs que to process
    @contractors = Contractor.where(commercial: true).includes(:account).where(accounts: { country_id: country.id })
    @contractors.each do |contractor|
      JobMailer.notify_contractor_suitable_commercial_job(contractor, self).deliver
    end
  end

  def notify_homeowner
    JobMailer.notify_homeowner_commercial_job_approved(homeowner, self).deliver
    homeowner.notify 'Your job has been approved'
  end

  def send_sms_for_suitable_job_post
  end

  def thank_homeowner_for_posting_a_job
    JobMailer.thank_homeowner_for_posting_a_commercial_job(homeowner, self).deliver
  end

  def notify_homeowner_commercial_job_quoted(bid_contractor)
    JobMailer.notify_homeowner_commercial_job_quoted(homeowner, bid_contractor, self).deliver
    homeowner.notify "Your job has been quoted by #{bid_contractor.company_name}"
  end

  def notify_contractor_commercial_job_quote_accepted(bid_contractor)
    JobMailer.notify_contractor_commercial_job_quote_accepted(homeowner, bid_contractor, self).deliver
    homeowner.notify "Your quote has been accepted by #{homeowner.first_name}"
  end

  def notify_homeowner_commercial_job_bided(bid_contractor)
    JobMailer.notify_homeowner_commercial_job_bided(homeowner, bid_contractor, self).deliver
    homeowner.notify "Your job has been interested by #{bid_contractor.company_name}"
  end

  # rubocop:disable Style/PredicateName
  def is_pendding?
    state == 'pending'
  end

  def is_completed?
    state == 'complete'
  end

  def self.account_jobs(state, account, page)
    jobs = state_jobs(state)
    if account.agent?
      jobs = jobs.where('homeowner_id=? OR partner_id = ?', account.id, account.id)
    else
      jobs = jobs.includes(:bids).where(homeowner_id: account.id)
    end
    jobs.order('created_at DESC').paginate(page: page, per_page: 10)
  end

  private

  def set_partner
    self.partner_id = homeowner.id if homeowner.agent
  end

  def normalize_mobile_number
    @client_mobile = true if client_mobile_number
    normalized = Textable.normalize(client_mobile_number, default_phone_code: country.try(:default_phone_code))
    return if normalized == client_mobile_number
    client_mobile_number_will_change!
    self.client_mobile_number = normalized
  end

  def client_mobile_number_validation
    errors.add(:client_mobile_number, 'is invalid') if client_mobile_number.nil? && @client_mobile
  end
end
