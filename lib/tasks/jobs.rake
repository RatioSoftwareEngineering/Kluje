desc 'auto archive jobs'
task auto_archive_jobs: :environment do
  compare_date = Date.current
  # Archive jobs were approved 6 months ago
  compare_date -= (30 * 6)
  Job.approved.not_archived.where('approved_at < ?', compare_date).find_each(&:archive)
end
