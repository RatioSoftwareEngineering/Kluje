FactoryGirl.define do
  factory :job do
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
  end
end
