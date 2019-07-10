# == Schema Information
#
# Table name: feature_payments
#
#  id            :integer          not null, primary key
#  contractor_id :integer
#  amount        :decimal(13, 2)   not null
#  feature_name  :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class FeaturePayment < ActiveRecord::Base
  belongs_to :contractor
end
