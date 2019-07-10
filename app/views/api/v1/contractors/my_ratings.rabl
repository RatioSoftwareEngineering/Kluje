collection @ratings
  attributes :contractor_id,:job_id,:last_name,:professionalism,:quality,:value,:comments,:score,:approved_at,:created_at,:updated_at, :errors


child :job do
	extends "api/v1/contractors/jobs/job"
end
