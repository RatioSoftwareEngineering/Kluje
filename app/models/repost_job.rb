# == Schema Information
#
# Table name: repost_jobs
#
#  id         :integer          not null, primary key
#  old_job_id :integer
#  new_job_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class RepostJob < ActiveRecord::Base
  belongs_to :job, class_name: 'Job', foreign_key: 'old_job_id'
  belongs_to :job, class_name: 'Job', foreign_key: 'new_job_id'
end
