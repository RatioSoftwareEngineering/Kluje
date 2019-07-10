module SMS
  @queue = :sms
  def self.perform(job, premium)
    job = Residential::Job.find(job['id'])
    return if job.maximum_no_of_bids_reached?
    job.send_sms_for_suitable_job_post premium
  end
end
