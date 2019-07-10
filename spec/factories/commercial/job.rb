FactoryGirl.define do
  factory :commercial_job, class: Commercial::Job do
    state 'approved'
    approved_at Time.now
    availability_id 1
    budget_id 14
    postal_code '139951'
    job_category_id 172
    skill_id 13
    description 'This is a sample description that is more than 30 characters.'
    city City.last
    homeowner { create :account }
    property_type 1
    renovation_type 1
    budget_value 1000
    start_date Time.now
    address '12345'
    floor_size 1
  end
end
