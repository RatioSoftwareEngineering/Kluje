module Mail
  @queue = :mail

  def self.perform(job, premium)
    job = Residential::Job.find(job['id'])
    return if job.maximum_no_of_bids_reached?
    job.notify_contractors_suitable_job premium
  end
end
