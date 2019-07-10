# == Schema Information
#
# Table name: job_categories
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  description :text(65535)
#  skill_id    :integer          not null
#  deleted_at  :datetime
#  created_at  :datetime
#  updated_at  :datetime
#  min_budget  :decimal(10, )    not null
#  max_budget  :decimal(10, )
#

class JobCategory < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true
  belongs_to :skill

  after_save { Rails.cache.delete :skills_and_job_categories }

  def budgets
    Budget.where('end_price > ? AND start_price < ?', min_budget, max_budget)
  end

  def translated_name
    FastGettext._(name)
  end
end
