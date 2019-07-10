# == Schema Information
#
# Table name: ratings
#
#  id              :integer          not null, primary key
#  job_id          :integer          not null
#  contractor_id   :integer          not null
#  professionalism :integer          default(0), not null
#  quality         :integer          default(0), not null
#  value           :integer          default(0), not null
#  comments        :text(65535)
#  score           :decimal(5, 2)
#  approved_at     :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class Commercial::Rating < Rating
end
