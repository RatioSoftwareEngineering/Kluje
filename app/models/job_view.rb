# == Schema Information
#
# Table name: job_views
#
#  id            :integer          not null, primary key
#  job_id        :integer
#  contractor_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class JobView < ActiveRecord::Base
  belongs_to :job
  belongs_to :contractor
end
