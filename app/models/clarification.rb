# == Schema Information
#
# Table name: clarifications
#
#  id            :integer          not null, primary key
#  job_id        :integer          not null
#  contractor_id :integer          not null
#  question      :string(255)
#  answer        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Clarification < ActiveRecord::Base
  belongs_to :job
  belongs_to :contractor
end
