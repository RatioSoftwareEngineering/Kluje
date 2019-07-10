# == Schema Information
#
# Table name: credits
#
#  id            :integer          not null, primary key
#  contractor_id :integer
#  amount        :decimal(13, 2)   not null
#  deposit_type  :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  discount      :decimal(10, )
#  currency      :string(255)      default("sgd")
#

class Credit < ActiveRecord::Base
  belongs_to :contractor

  attr_accessible :amount, :currency, :contractor_id, :deposit_type

  scope :latest, -> { order('created_at DESC').limit(1) }

  validates :amount, numericality: { message: _('Please enter a valid amount.') }

  def txn_id
    'Admin Top Up'
  end

  def status
    'Admin Top Up'
  end
end
