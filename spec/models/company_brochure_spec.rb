# == Schema Information
#
# Table name: company_brochures
#
#  id            :integer          not null, primary key
#  contractor_id :integer
#  file          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe CompanyBrochure, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
