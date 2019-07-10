# == Schema Information
#
# Table name: phone_verifications
#
#  id                           :integer          not null, primary key
#  account_id                   :integer
#  mobile_number                :string(255)
#  verification_code            :string(255)
#  verification_code_expires_at :datetime
#  ip                           :string(255)
#  verified                     :boolean
#  created_at                   :datetime
#  updated_at                   :datetime
#

class PhoneVerification < ActiveRecord::Base
  include Secure
  include Textable

  CODE_LENGTH = 5
  CODE_VALIDITY = 10.minutes

  belongs_to :account

  before_validation :normalize_mobile_number
  before_validation :generate_verification_code

  delegate :country, to: :account

  validates :mobile_number, presence: true

  scope :active, -> { where('verification_code_expires_at >= ?', Time.zone.now) }
  scope :account, ->(account) { where('account_id IS NULL OR account_id = ?', account.id) }

  def country
    account && account.country
  end

  def generate_verification_code
    return if verification_code
    update_attributes(verification_code: secure_code(CODE_LENGTH),
                      verification_code_expires_at: Time.zone.now + CODE_VALIDITY)
  end

  def send_verification_code(_retry_no = 0)
    msg = "Your Kluje.com verification code is #{verification_code}"
    nexmo_sms msg
  end

  def verify_code(code)
    if secure_compare(code, verification_code) && verification_code_expires_at >= Time.zone.now
      update_attributes(verification_code_expires_at: Time.zone.now,
                        verified: true)

      true
    else
      false
    end
  end
end
