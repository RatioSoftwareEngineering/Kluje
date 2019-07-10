object @job

attributes :id, :homeowner_id, :contractor_id, :job_category_id, :skill_id,
	   :budget_id, :description, :availability_id, :postal_code, :lat, :lng,
	   :state, :purchased_at, :approvated_at, :deleted_at, :created_at,
	   :updated_at, :contact_time_id, :archived_at, :property_type, :code,
	   :image, :priority_level

child(:homeowner) { attributes :first_name, :last_name, :email, :role, :locale,
                               :mobile_number, :uid,
                               :provider, :suspended_at, :created_at,
                               :updated_at }
