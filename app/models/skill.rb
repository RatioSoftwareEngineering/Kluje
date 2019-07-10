# == Schema Information
#
# Table name: skills
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  description :text(65535)
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

class Skill < ActiveRecord::Base
  acts_as_paranoid

  has_and_belongs_to_many :contractors
  has_many :job_categories

  after_save { Rails.cache.delete :skills_and_job_categories }

  def translated_name
    FastGettext._(name)
  end

  def self.skills_table
    skills = Skill.all.map do |s|
      job_categories = s.job_categories.map { |j| [j.id, j.translated_name] }
      [s.id, { name: s.name, job_categories: Hash[job_categories] }]
    end
    Hash[skills].to_json
  end
end
