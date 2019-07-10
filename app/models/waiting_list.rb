# == Schema Information
#
# Table name: waiting_lists
#
#  id            :integer          not null, primary key
#  contractor_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class WaitingList < ActiveRecord::Base
  belongs_to :contractor
end
