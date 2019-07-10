# == Schema Information
#
# Table name: accounts
#
#  id                      :integer          not null, primary key
#  first_name              :string(150)
#  last_name               :string(150)
#  email                   :string(255)
#  encrypted_password      :string(255)      default(""), not null
#  role                    :string(255)
#  contractor_id           :integer
#  locale                  :string(255)      default("en"), not null
#  mobile_number           :string(255)
#  subscribe_newsletter    :boolean          default(TRUE), not null
#  reset_password_token    :string(255)
#  reset_password_sent_at  :datetime
#  deleted_at              :datetime
#  created_at              :datetime
#  updated_at              :datetime
#  suspended_at            :datetime
#  account_id              :integer
#  no_of_account           :integer
#  uid                     :string(255)
#  provider                :string(255)
#  property_agent_id       :integer
#  cea_number              :string(255)
#  facilities_manager_id   :integer
#  country_id              :integer
#  email_verification_code :string(255)
#  confirmation_token      :string(255)
#  confirmed_at            :datetime
#  confirmation_sent_at    :datetime
#  unconfirmed_email       :string(255)
#  agent                   :boolean
#  partner_code            :string(255)
#

# rubocop:disable Metrics/ClassLength
class Account < ActiveRecord::Base
  include PushNotifiable
  include Secure
  include Textable
  include EncryptHelper

  acts_as_paranoid

  belongs_to :contractor, dependent: :destroy
  belongs_to :country
  has_many :devices
  has_many :jobs, foreign_key: :homeowner_id
  has_many :partner_jobs, foreign_key: :partner_id, class_name: 'Commercial::Job'
  has_many :invoices, foreign_key: :homeowner_id
  has_many :questions
  has_many :answers

  has_one :api_key

  devise :database_authenticatable, :registerable, :recoverable, :confirmable, pepper: Kluje.settings.pepper

  # Ransack converts 1 to true, which results in no arguments error. Added default value as workaround.
  scope :contractor_city_eq, ->(city_id = 1) {
    joins(contractor: :cities).where('contractors_cities.city_id = ?', city_id)
  }

  def self.ransackable_scopes(_auth_object = nil)
    [:contractor_city_eq]
  end

  accepts_nested_attributes_for :contractor

  def password_required?
    uid.blank? && encrypted_password.blank?
  end

  def social_login?
    uid.present?
  end

  before_validation :normalize_mobile_number

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, unless: :social_login?
  # validates :email, uniqueness: {
  #                     message: '%{value} already has an account with us. Please sign in before posting.'
  #                   }, unless: :social_login?
  validate :uniqueness_email
  validates :password, presence: true, if: :password_required?
  validates :password, length: { in: 6..20 }, if: :password_required?
  validates :mobile_number, uniqueness: {
    message: '%{value} already has an account with us. Please sign in before posting.'
  }, allow_blank: true, allow_nil: true, on: :create
  validates :partner_code, uniqueness: true, allow_blank: true

  # Callbacks
  before_validation :downcase_email
  before_save :set_locale
  before_create :ensure_role
  after_create :generate_api_key
  after_destroy :change_uniq_info

  # base scopes
  scope :approved, -> { joins(:contractor).where('contractors.approved = ?', true) }
  scope :country, ->(country_id) { where(country_id: country_id) }
  scope :email_verified, -> { where('confirmed_at <= ?', Time.zone.now) }
  scope :role, ->(*role) { where(role: role) }
  scope :suspended, -> { where('suspended_at IS NOT NULL') }

  # negative scopes
  scope :not_email_verified, -> { where('confirmed_at IS NULL') }
  scope :not_active, -> { not_suspended.not_email_verified }
  scope :not_approved, -> { joins(:contractor).where('contractors.approved = ?', false) }
  scope :not_suspended, -> { where('suspended_at IS NULL') }

  # convenience scopes
  scope :active, -> { email_verified.not_suspended }
  scope :admin, -> { role('admin', 'country_admin') }
  scope :contractor, -> { role('contractor') }
  scope :homeowner, -> { role('homeowner') }
  scope :agent, -> { role('homeowner').where('agent' => true) }
  scope :unverified, -> { approved.where('contractors.verified != ? OR contractors.verified IS NULL', true) }
  scope :verified, -> { approved.where('contractors.verified' => true) }
  scope :verification_request, -> {
    approved.where('contractors.verification_request =? AND contractors.verified IS NULL', true)
  }
  scope :request_commercial, -> {
    approved.where('contractors.request_commercial =? AND contractors.commercial =?', true, false)
  }

  scope :newsletters, -> { approved.active.where(subscribe_newsletter: true) }

  def add_device(platform, token = '')
    token.gsub!(/[<> ]/, '') if token
    device = Device.find_or_create_by(token: token, platform: platform)
    device.update_attributes account: self
    device
  end

  def generate_api_key
    return if admin?

    api_key = ApiKey.new
    api_key.account = self
    api_key.save
  end

  def email_verify
    update_attribute(:confirmed_at, Time.zone.now)
  end

  def email_verified?
    confirmed_at.present? && confirmed_at <= Time.zone.now
  end

  # rubocop:disable Style/PredicateName
  def is_email_verified
    email_verified? ? '1' : '0'
  end

  def mobile_verified?
    mobile_number.present?
  end

  def ensure_role
    self.role = contractor.present? ? 'contractor' : 'homeowner' unless role
  end

  def admin?
    role == 'admin' || role == 'country_admin' || role == 'analytics'
  end

  def country_admin?
    role == 'country_admin'
  end

  def global_admin?
    role == 'admin'
  end

  def analytics?
    role == 'analytics'
  end

  def agent?
    role == 'homeowner' && agent == true
  end

  def contractor?
    role == 'contractor'
  end

  def homeowner?
    role == 'homeowner'
  end

  def commercial?
    (role == 'homeowner' && jobs.commercial.present?) ||
      (role == 'contractor' && contractor.commercial?)
  end

  def active?
    email_verified? && suspended_at.nil?
  end

  def known_contractor_ids
    jobs.joins(:bids).pluck('bids.contractor_id')
  end

  def last_postal_code
    jobs.last.try(:postal_code)
  end

  def suspended?
    suspended_at.present?
  end

  def suspend
    touch(:suspended_at)
  end

  def unsuspend
    update_attribute(:suspended_at, nil)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def random_token
    SecureRandom.urlsafe_base64(8).tr('lIO0', 'sxyz')
  end

  def generate_sms_confirm_code
    rand.to_s[2..7]
  end

  def verify_mobile(number, code)
    number = Textable.normalize(number, default_phone_code: country.default_phone_code)
    verifications = PhoneVerification.active.account(self).where(mobile_number: number)
    verifications.each do |verification|
      next unless verification.verify_code(code)
      verification.update_attributes(account: self)
      update_attributes(mobile_number: number)
      contractor.try(:update_attributes, mobile_alerts: true)
      return true
    end
    false
  end

  def is_verification_request?
    (role == 'contractor') && contractor.verification_request? && !contractor.verified?
  end

  def is_request_commercial?
    (role == 'contractor') && contractor.request_commercial? && !contractor.commercial?
  end

  def accept_request_commercial
    contractor.update_attribute(:commercial, true)
  end

  def bill_to
    return contractor.company_name if contractor? && contractor.company_name
    first_name + ' ' + last_name
  end

  def self.commercial_subscribe
    accounts = contractor.select { |a| a.contractor.commercial_subscribe? }
    Account.where(id: accounts.map(&:id))
  end

  def can_approve?
    email_verified? && contractor && !contractor.approved?
  end

  def can_verify_contractor?
    contractor && contractor.approved? && !contractor.verified?
  end

  def encrypted_email
    encryption(email)
  end

  private

  def after_confirmation
    jobs.each do |job|
      next if job.commission?
      job.approve if job.type != 'Commercial::Job'
      job.save
      job.thank_homeowner_for_posting_a_job
    end
  end

  def downcase_email
    email.try(:downcase!)
  end

  def set_locale
    self.locale = I18n.locale.downcase ||= 'en'
  end

  def change_uniq_info
    skip_reconfirmation!
    update_attribute(:email, deleted_at.to_i.to_s + '_' + email)
    update_attribute(:mobile_number, deleted_at.to_i.to_s + '_' + mobile_number) if mobile_number
    update_attribute(:partner_code, deleted_at.to_i.to_s + '_' + partner_code) if partner_code
  end

  def uniqueness_email
    return unless Account.where(email: email, uid: nil).where.not(id: id).count > 0
    errors.add(:email, "#{email} already has an account with us. Please sign in before posting.")
  end
end
