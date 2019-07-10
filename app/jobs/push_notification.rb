module PushNotification
  @queue = :notification_sender

  def self.perform(job, title, message, premium)
    job = Residential::Job.find(job['id'])
    return if job.maximum_no_of_bids_reached?
    job.suitable_contractors.each do |contractor|
      # Remove premium membership
      # if contractor.premium? == !!premium && contractor.cities.include?(job.city)
      if contractor.cities.include?(job.city)
        contractor.account.notify title, message
      end
    end
  end
end
