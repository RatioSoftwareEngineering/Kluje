# == Schema Information
#
# Table name: invoices
#
#  id                 :integer          not null, primary key
#  sender_id          :integer
#  sender_type        :string(255)
#  recipient_id       :integer
#  recipient_type     :string(255)
#  job_id             :integer
#  amount             :decimal(15, 2)
#  currency           :string(255)
#  number             :string(255)
#  file               :string(255)
#  paid               :boolean
#  created_at         :datetime
#  updated_at         :datetime
#  commission         :integer
#  concierge          :decimal(10, )
#  partner_commission :integer          default(0)
#

class Invoice < ActiveRecord::Base
  validates :amount, presence: true

  belongs_to :sender, polymorphic: true
  belongs_to :recipient, polymorphic: true
  belongs_to :job

  mount_uploader :file, DocumentUploader

  enum partner_commission: { no_need: 0, need_to_be_paid: 1, partner_commission_paid: 2 }

  scope :homeowner_search, ->(homeowner) {
    joins(:job).where("recipient_id = ? AND jobs.state LIKE 'complete'", homeowner.id)
  }
  scope :contractor_search, ->(contractor) {
    joins(:job).where("sender_id = ? AND jobs.state LIKE 'complete'", contractor.id)
  }
  scope :partner_search, ->(partner) {
    joins(:job).where(
      "(recipient_id = ? OR partner_id = ? )AND jobs.state LIKE 'complete'",
      partner.id, partner.id
    )
  }

  def image?
    file_url.present? && self[:file].downcase =~ /jpg|jpeg|gif|png/
  end

  def document?
    file_url.present? && !image?
  end

  def self.account_search(account)
    if account.contractor?
      contractor_search(account.contractor)
    elsif account.agent?
      partner_search(account)
    else
      homeowner_search(account)
    end
  end
end
