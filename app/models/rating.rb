# == Schema Information
#
# Table name: ratings
#
#  id              :integer          not null, primary key
#  job_id          :integer          not null
#  contractor_id   :integer          not null
#  professionalism :integer          default(0), not null
#  quality         :integer          default(0), not null
#  value           :integer          default(0), not null
#  comments        :text(65535)
#  score           :decimal(5, 2)
#  approved_at     :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class Rating < ActiveRecord::Base
  belongs_to :job
  belongs_to :contractor

  validate :check_duplicates, on: :create
  validates :professionalism, presence: true, format: { with: /[1-5]/ }
  validates :quality, presence: true, format: { with: /[1-5]/ }
  validates :value, presence: true, format: { with: /[1-5]/ }

  before_save :calculate_score
  after_save :update_contractor_score

  after_create :thank_homeowner_for_rating

  scope :approved, -> { where('ratings.approved_at IS NOT NULL') }
  scope :residential, -> { joins(:job).where('jobs.type = ?', 'Residential::Job') }
  scope :commercial, -> { joins(:job).where('jobs.type = ?', 'Commercial::Job') }

  def approve
    touch(:approved_at)
  end

  def approved?
    approved_at.present?
  end

  def thank_homeowner_for_rating
    return unless job.homeowner
    if job.commercial?
      RatingMailer.thank_client_for_rating(job.homeowner, contractor, job).deliver_now
    else
      RatingMailer.thank_homeowner_for_rating(job.homeowner, contractor, job).deliver_now
    end
  end

  private

  def check_duplicates
    return unless self.class.where('job_id = ? && contractor_id = ?', job_id, contractor_id).exists?
    errors.add(:rating, _('Already submitted previously!'))
  end

  def calculate_score
    self.score = ([professionalism, quality, value].sum / 3).to_f
  end

  def update_contractor_score
    contractor.update_score
    contractor.update_average_rating
  end
end
