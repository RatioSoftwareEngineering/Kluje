# == Schema Information
#
# Table name: contractors
#
#  id                           :integer          not null, primary key
#  company_name                 :string(255)      not null
#  company_street_no            :string(255)
#  company_street_name          :string(255)
#  company_unit_no              :string(255)
#  company_building_name        :string(255)
#  company_postal_code          :string(255)
#  company_name_slug            :string(255)      not null
#  company_logo                 :string(255)
#  nric_no                      :string(255)
#  uen_number                   :string(255)
#  bca_license                  :string(255)
#  hdb_license                  :string(255)
#  billing_name                 :string(255)
#  billing_address              :text(65535)
#  billing_postal_code          :string(255)
#  billing_phone_no             :string(255)
#  mobile_alerts                :boolean          default(TRUE), not null
#  email_alerts                 :boolean          default(TRUE), not null
#  score                        :integer
#  deleted_at                   :datetime
#  created_at                   :datetime
#  updated_at                   :datetime
#  company_description          :text(65535)
#  pub_license                  :string(255)
#  ema_license                  :string(255)
#  case_member                  :string(255)
#  scal_member                  :string(255)
#  bizsafe_member               :string(255)
#  selected_header_image        :string(255)
#  crop_x                       :string(255)
#  crop_y                       :string(255)
#  crop_w                       :string(255)
#  crop_h                       :string(255)
#  parent_id                    :integer
#  sms_count                    :integer
#  is_deactivated               :boolean
#  office_number                :string(255)
#  verified                     :boolean
#  photo_id                     :string(255)
#  business_registration        :string(255)
#  bids_count                   :integer          default(0)
#  average_rating               :float(24)        default(0.0)
#  approved                     :boolean          default(FALSE)
#  commercial                   :boolean          default(FALSE), not null
#  accept_agreement             :boolean
#  company_red                  :datetime
#  company_rn                   :string(255)
#  company_rd                   :string(255)
#  date_incor                   :datetime
#  relevant_activitie           :string(255)
#  association_name             :string(255)
#  membership_no                :string(255)
#  financial_report             :string(255)
#  bank_statement               :string(255)
#  legal                        :boolean
#  legal_text                   :string(255)
#  request_commercial           :boolean          default(FALSE)
#  verification_request         :boolean          default(FALSE)
#  commercial_registration_date :datetime
#

# rubocop:disable Metrics/ClassLength, Style/PredicateName
class Contractor < ActiveRecord::Base
  acts_as_paranoid

  mount_uploader :company_logo, ProfileImageUploader
  mount_uploader :selected_header_image, HeaderImageUploader
  mount_uploader :photo_id, DocumentUploader
  mount_uploader :business_registration, DocumentUploader

  mount_uploader :company_rd, DocumentUploader
  mount_uploader :financial_report, DocumentUploader
  mount_uploader :bank_statement, DocumentUploader

  has_one :account, autosave: true
  has_many :feature_payments
  has_many :bids
  has_many :invoices
  has_many :clarifications
  has_many :ratings
  has_many :meetings
  has_many :credits
  has_many :contractor_skills, class_name: 'ContractorsSkill'
  has_many :photos
  has_many :purchased_jobs, foreign_key: :contractor_id, class_name: 'Job'
  has_many :top_ups, class_name: 'Paypal::TopUp'
  has_many :subscription_payments, class_name: 'Paypal::SubscriptionPayment'
  has_many :company_brochures, dependent: :destroy
  accepts_nested_attributes_for :company_brochures
  has_many :company_projects, dependent: :destroy
  accepts_nested_attributes_for :company_projects
  has_many :subscriptions, dependent: :destroy

  has_and_belongs_to_many :cities, join_table: 'contractors_cities'
  has_and_belongs_to_many :skills

  accepts_nested_attributes_for :account, reject_if: :all_blank
  has_one :waiting_list

  scope :active, -> {
    joins(:account)
      .where('accounts.suspended_at IS NULL')
      .where('accounts.confirmed_at IS NOT NULL')
  }
  scope :country, ->(country_id) { joins(:account).where('accounts.country_id' => country_id) }
  scope :city, ->(city_id) { joins(:cities).where('cities.id' => city_id) }
  scope :top, -> { active.order('score DESC') }

  before_validation do
    nric_no.upcase! if nric_no.present?
  end

  # Validations
  validates_associated :account
  validates :company_name, presence: true
  validates :nric_no, format: { with: /\A(S|T)\d{7}[A-Z]\z/, message: _('is invalid.') }, allow_blank: true
  validates :hdb_license, format: { with: /\A(HB)/ }, allow_blank: true
  validates :pub_license, format: { with: /\A(WS)\d{8}\z/ }, allow_blank: true
  validates :ema_license, format: { with: /\A\d{6,7}\z/ }, allow_blank: true
  validate :uen_no_cannot_be_invalid
  validate :validate_miximum_logo_size, on: :update

  # validate :validate_miximum_header_size, :on => :update
  validates :uen_number, uniqueness: {
    case_sensitive: false,
    message: '%{value} already has an account with us.  Please sign in before posting.'
  }, on: :create, allow_nil: true, allow_blank: true

  validates :company_name, uniqueness: {
    case_sensitive: false,
    message: '%{value} already has an account with us.  Please sign in before posting.'
  }, on: :create

  with_options if: :verification_request? do |c|
    c.validates :company_red, presence: true, allow_blank: false
    c.validates :company_rn, presence: true, allow_blank: false
    c.validates :date_incor, presence: true, allow_blank: false
    c.validates :company_rd, presence: true, allow_blank: false
    c.validates :company_street_no, presence: true, allow_blank: false
    c.validates :association_name, presence: true, allow_blank: false
    c.validates :membership_no, presence: true, allow_blank: false
  end

  delegate :email_verify, to: :account
  delegate :suspend, to: :account
  delegate :unsuspend, to: :account

  before_save do
    self.company_name_slug = company_name.parameterize
  end

  def self.mandatory_company_details
    [:company_name]
  end

  def approve
    update_attribute(:approved, true)
  end

  def archived
    purchased_leads
      .select do |job|
      !job.ratings.pluck(:contractor_id).include? id
    end
  end

  def can_bid_for_job?(job)
    account.active? && cities.include?(job.city) &&
      !has_bidded_for_job?(job) &&
      has_credits_for_bid?(job)
  end

  def has_credits_for_bid?(job)
    residential_subscribe? || credits_balance >= job.lead_price
  end

  def can_bid_for_commercial_job?(job)
    account.active? && cities.include?(job.city) &&
      !has_bidded_for_job?(job)
  end

  def company_details_completed?
    self.class.mandatory_company_details.each do |attr_name|
      if attr_name == :mobile_number
        return false if account.read_attribute(attr_name.to_s).blank?
      else
        return false if self[attr_name.to_s].blank?
      end
    end
    true
  end

  def credits_amount
    credits.sum('amount').to_f
  end

  def credits_balance
    balance = credits_amount
    balance -= credits_spent_on_bids
    balance -= credits_spent_on_sms
    balance.round(2)
  end

  def credits_spent_on_bids
    bids.sum('amount').to_f
  end

  def credits_spent_on_sms
    feature_payments.where(feature_name: 'SMS').sum(:amount).to_f
  end

  def credits_spent(start_date, end_date, currency)
    if start_date
      bids.where(
        'created_at >= ? AND created_at < ? AND currency = ?', start_date, end_date, currency
      ).sum('amount').to_f \
      + feature_payments.where(
        "feature_name = 'SMS' AND created_at >= ? AND created_at < ?", start_date, end_date
      ).sum(:amount).to_f
    else
      bids.where('created_at < ? AND currency = ?', end_date, currency).sum('amount').to_f\
      + feature_payments.where("feature_name = 'SMS' AND created_at < ?", end_date).sum(:amount).to_f
    end
  end

  def credits_free(currency)
    credits.where(
      "(deposit_type = 'sign_up_bonus' OR deposit_type = 'admin_top_up') AND currency = ? ", currency
    ).sum(:amount).to_f
  end

  def documents_submitted?
    photo_id.present? && business_registration.present?
  end

  def has_bidded_for_job?(job)
    Bid.exists?(job_id: job.id, contractor_id: id)
  end

  def has_viewed_job?(job_id)
    JobView.exists?(job_id: job_id, contractor_id: id)
  end

  def is_eligible_to_purchase_leads?
    !skill_ids.empty? && company_details_completed?
  end

  def has_meeting_for_job?(job)
    Meeting.exists?(job_id: job.id, contractor_id: id)
  end

  def has_invoice_for_job?(job)
    Invoice.exists?(job_id: job.id, sender_id: id)
  end

  def cache_job_leads
    jobs_updated_at = Residential::Job.maximum(:updated_at)
    Rails.cache.fetch([self, 'job_leads', jobs_updated_at]) do
      job_leads.map(&:id)
    end
  end

  def job_leads
    # job_ids = []
    another_specific_job_ids = Residential::Job.where("specific_contractor_id != ''")
                               .where('specific_contractor_id != ?', id).pluck(:id)
    repost_job_ids = RepostJob.where(old_job_id: bids.pluck(:job_id)).pluck(:new_job_id)

    excluded_jobs = another_specific_job_ids + repost_job_ids

    # list = []
    jobs = Residential::Job.with_state(:approved, :bidded)
           .where('jobs.skill_id IN (?)', skill_ids)
           .where('jobs.city_id IN (?)', cities.pluck(:id))
           .where('jobs.homeowner_ID != ?', account.id)
    jobs = jobs.where('jobs.id NOT IN (?)', excluded_jobs) if excluded_jobs.present?
    jobs = jobs.select { |job| !job.maximum_no_of_bids_reached? && !has_bidded_for_job?(job) }
    jobs
  end

  def commercial_job_leads
    #  = []
    another_specific_job_ids = Commercial::Job.where("specific_contractor_id != ''")
                               .where('specific_contractor_id != ?', id).pluck(:id)
    repost_job_ids = RepostJob.where(old_job_id: bids.pluck(:job_id)).pluck(:new_job_id)

    excluded_jobs = another_specific_job_ids + repost_job_ids

    # list = []

    jobs = Commercial::Job.with_state(:approved, :bidded)
           .where('jobs.city_id IN (?)', cities.pluck(:id))
           .where('jobs.homeowner_ID != ?', account.id)
    jobs = jobs.where('jobs.id NOT IN (?)', excluded_jobs) if excluded_jobs.present?
    jobs = jobs.select { |job| !job.maximum_no_of_bids_reached? && !has_bidded_for_job?(job) }
    jobs
  end

  def update_score
    rating_scores = ratings.approved.pluck(:score) + [2.5, 2.5]
    rating_score = (rating_scores.sum * 20 / rating_scores.length).to_i
    bids_score = bids.length * 10
    update_attribute(:score, rating_score + bids_score)
  end

  def update_average_rating
    update_attribute(:average_rating, ratings.approved.average(:score) || 0.0)
  end

  def premium?
    premium_expires_at > Time.zone.now
  end

  def premium_expires_at
    return Time.zone.now - 1.year unless account.country
    latest = credits.where('amount >= ?', account.country.top_up_amounts.last).latest.pluck(:created_at).first
    (latest || Time.zone.now - 1.year) + 30.days
  end

  def profile_url
    Rails.application.routes.url_helpers.profile_contractors_url(slug: company_name_slug, locale: locale_country)
  end

  def purchased_leads
    Residential::Job.with_state(:purchased, :bidded, :archived).find(bids.pluck(:job_id))
  end

  # Custom validation
  def uen_no_cannot_be_invalid
    # Regex based on http://www.uen.gov.sg/uen/html/uenWriteUp.html
    return unless uen_number.present?
    business_registered = /\d{8}[A-Z]/ # 12345678F
    local_companies = /\d{9}[A-Z]/ # 123456789F
    entities_with_new_uen = /^T\d{2}[A-Z]{2}\d{4}[A-Z]$/ # T11LL1234F
    return if business_registered.match(uen_number).present? || \
              local_companies.match(uen_number).present? || \
              entities_with_new_uen.match(uen_number).present?

    errors.add(:uen_no, _('is invalid.'))
  end

  def mobile_alerts?
    mobile_alerts && !is_deactivated
  end

  def email_alerts?
    email_alerts && !is_deactivated
  end

  def update_sms_count
    if sms_count > 0
      update_attribute(:sms_count, sms_count - 1)
    elsif mobile_alerts? && credits_balance >= account.country.sms_bundle_price
      FeaturePayment.create(contractor_id: id, amount: account.country.sms_bundle_price, feature_name: 'SMS')
      update_attribute(:sms_count, 99)
    else
      update_attribute(:mobile_alerts, '0')
      false
    end
  end

  def verify
    self.verified = true
  end

  def accept_request_commercial
    update_attributes(commercial: true, commercial_registration_date: Time.zone.now)
    CommercialMailer.notify_contractor_access_commercial(self).deliver
  end

  def company_address
    address = company_street_no
    address << (' ' + company_street_name) if company_street_name
    address << (' ' + company_unit_no) if company_unit_no
    address << (' ' + company_building_name) if company_building_name
    address
  end

  def residential_subscribe?
    return false if subscriptions.residential.empty?
  end

  def commercial_subscribe?
    return false if subscriptions.commercial.empty?
    Subscription.reload(self)
    subscriptions.commercial.maximum(:expired_at) > Time.zone.now
  end

  def residential_subscription_expiry_date
    subscriptions.residential.maximum(:expired_at) if subscriptions.residential.present?
  end

  def commercial_subscription_expiry_date
    subscriptions.commercial.maximum(:expired_at) if subscriptions.commercial.present?
  end

  def check_renewed_subscription
    s = subscriptions.order(desc: :expired_at).limit(1)[0]
    Subscription.reload if s.auto_reload
  end

  def unsubscribe
    result = Braintree::Subscription.cancel(subscription_payments.last.braintree_subscription_id)
    if result.success?
      commercial_subscription_expiry_date.strftime('%d-%b-%Y')
    else
      false
    end
  end

  private

  # rubocop:disable Style/GuardClause
  def validate_miximum_logo_size
    if company_logo && company_logo.file
      path = company_logo.file.path.to_s
      if File.exist?(path)
        image = MiniMagick::Image.open(path)
        errors.add :company_logo, 'Image size is too large.' if image[:size] > 5_011_812
      end
    end
  end

  def validate_miximum_header_size
    if selected_header_image && selected_header_image.file
      path = selected_header_image.path.to_s
      if File.exist?(path)
        image = MiniMagick::Image.open(path)
        errors.add :header_image, 'size is too large.' if image[:size] > 5_011_812
      end
    end
  end

  def locale_country
    (I18n.locale || I18n.default_locale).to_s + '-' + account.country.cca2
  end

  def locale
    (I18n.locale || I18n.default_locale).to_s
  end
end
