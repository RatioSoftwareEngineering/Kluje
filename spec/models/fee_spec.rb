# == Schema Information
#
# Table name: fees
#
#  id         :integer          not null, primary key
#  country_id :integer
#  commission :integer          default(10)
#  concierge  :decimal(10, )    default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Fee, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
