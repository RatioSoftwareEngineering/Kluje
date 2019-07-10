# == Schema Information
#
# Table name: meetings
#
#  id            :integer          not null, primary key
#  job_id        :integer          not null
#  contractor_id :integer          not null
#  date          :date
#  time          :time
#  place         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  accept        :boolean
#  homeowner_id  :integer
#

class Meeting < ActiveRecord::Base
  belongs_to :job
  belongs_to :contractor
end
