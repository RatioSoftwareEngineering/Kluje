# == Schema Information
#
# Table name: jobs
#
#  id                        :integer          not null, primary key
#  homeowner_id              :integer
#  contractor_id             :integer
#  job_category_id           :integer
#  skill_id                  :integer
#  work_location_id          :integer
#  budget_id                 :integer
#  description               :text(65535)      not null
#  availability_id           :integer
#  postal_code               :string(255)
#  lat                       :decimal(15, 10)
#  lng                       :decimal(15, 10)
#  state                     :string(255)      default("pending")
#  purchased_at              :datetime
#  approved_at               :datetime
#  deleted_at                :datetime
#  created_at                :datetime
#  updated_at                :datetime
#  contact_time_id           :integer          default(0), not null
#  archived_at               :datetime
#  property_type             :integer
#  code                      :string(255)
#  image                     :string(255)
#  priority_level            :integer
#  specific_contractor_id    :integer
#  require_renovation_loan   :boolean
#  ref_code                  :string(255)
#  city_id                   :integer
#  client_type               :string(255)
#  renovation_type           :integer
#  floor_size                :integer
#  client_type_code          :string(255)
#  concierge_service         :boolean          default(TRUE)
#  address                   :string(255)
#  budget_value              :decimal(30, 10)
#  type                      :string(255)      default("Residential::Job")
#  start_date                :datetime
#  commission_rate           :integer          default(10), not null
#  concierges_service_amount :decimal(10, )    default(20)
#  number_of_quote           :integer          default(0)
#  client_first_name         :string(150)
#  client_last_name          :string(150)
#  client_email              :string(255)
#  client_mobile_number      :string(20)
#  partner_code              :string(255)
#  partner_id                :integer
#
# Indexes
#
#  index_jobs_on_state  (state)
#

class Residential::Job < Job
  validates :availability_id, presence: true
  validates :budget_id, presence: true # , unless: Proc.new { |job| job.type == 'Commercial::Job' }
  validates :job_category_id, presence: true
  validates :skill_id, presence: true

  def notify_contractors
    return if Padrino.env == :test || Padrino.env == :development
    Resque.enqueue SMS, self, true
    Resque.enqueue Mail, self, true
    Resque.enqueue PushNotification, self,
                   'Kluje', "A new job has been posted - #{skill.name} - #{job_category.name}.", true
    Resque.enqueue_in 3.hours, SMS, self, false
    Resque.enqueue_in 3.hours,  Mail, self, false
    Resque.enqueue_in 3.hours, PushNotification, self,
                      'Kluje', "A new job has been posted - #{skill.name} - #{job_category.name}.", false
  end

  def residential?
    true
  end
end
