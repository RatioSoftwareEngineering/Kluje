# == Schema Information
#
# Table name: contractors_skills
#
#  id            :integer          not null, primary key
#  contractor_id :integer
#  skill_id      :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class ContractorsSkill < ActiveRecord::Base
  belongs_to :contractor
  belongs_to :skill
end
