module DailyArchiveJob
  @queue = :daily_archive_job
  def self.perform()
    jobs = Residential::Job.includes(:bids).where(state: 'approved',bids:{id: nil})
    jobs.each do |job|
      unless job.job_expires_at.nil?
        if Date.parse((job.approved_at+job.job_expires_at.days).strftime('%d/%m/%Y')) <= Date.parse(Date.today.strftime('%d/%m/%Y'))
          job.archive
        end
      else
        job.archive
      end
    end

    # archive jobs are older than two weeks
    last_two_week = -14.days
    DailyArchiveJob.archive_jobs_older_than last_two_week
  end

  private 
  def self.archive_jobs_older_than period
    jobs = Residential::Job.where(state: ['approved', 'bidded', 'complete']).where("approved_at < \'#{period.from_now.utc}\'")
    jobs.each do |job|
      job.archive
    end
  end
end
