# == Schema Information
#
# Table name: subscriptions
#
#  id                      :integer          not null, primary key
#  contractor_id           :integer
#  expired_at              :datetime
#  auto_reload             :boolean          default(FALSE)
#  category                :integer
#  currency                :string(255)
#  price                   :decimal(13, 2)   default(0.0)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  subscription_payment_id :integer
#

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it { is_expected.to validate_presence_of(:contractor_id) }
  it { is_expected.to validate_presence_of(:expired_at) }
end
