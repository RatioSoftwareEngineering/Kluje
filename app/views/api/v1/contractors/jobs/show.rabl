object @job

attributes :id, :homeowner_id, :contractor_id, :job_cateogory_id, :skill_id,
           :budget_id, :description, :availability_id, :postal_code, :lat, :lng,
           :state, :purchased_at, :approvated_at, :deleted_at, :created_at,
           :updated_at, :contact_time_id, :archived_at, :property_type, :code,
           :image, :priority_level, :errors

if @contractor.has_bidded_for_job? @job
  child :homeowner do
    attributes :first_name, :last_name, :email, :mobile_number
  end
end

node :lead_price do |job|
  job.lead_price @contractor
end
