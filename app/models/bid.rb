# == Schema Information
#
# Table name: bids
#
#  id            :integer          not null, primary key
#  job_id        :integer
#  contractor_id :integer
#  amount        :decimal(13, 2)
#  created_at    :datetime
#  updated_at    :datetime
#  currency      :string(255)
#  accept        :boolean
#  amount_quoter :decimal(10, )    default(0)
#  file          :string(255)
#

class Bid < ActiveRecord::Base
  belongs_to :job
  belongs_to :contractor, counter_cache: true, touch: true

  before_save :set_lead_price

  mount_uploader :file, DocumentUploader

  def rating_submitted?
    rating = Rating.where(job_id: job_id, contractor_id: contractor_id).last
    rating ? true : false
  end

  def rating
    rating = Rating.where(job_id: job_id, contractor_id: contractor_id).last
    return rating.id unless rating.nil?
  end

  private

  def set_lead_price
    self.amount = 0 if contractor.residential_subscribe?
  end
end
