
# If you want to be able to dynamically change the schedule,
# uncomment this line.  A dynamic schedule can be updated via the
# Resque::Scheduler.set_schedule (and remove_schedule) methods.
# When dynamic is set to true, the scheduler process looks for
# schedule changes and applies them on the fly.
# Note: This feature is only available in >=2.0.0.
# Resque::Scheduler.dynamic = true
# Dir["#{Padrino.root}/app/jobs/*.rb"].each { |file| require file }

Dir["#{Padrino.root}/app/jobs/*.rb"].each { |file| require file }

# The schedule doesn't need to be stored in a YAML, it just needs to
# be a hash.  YAML is usually the easiest.
# Resque.schedule = YAML.load_file("#{Padrino.root}/config/resque_schedule.yml")

Resque.after_fork do |_job|
  Resque.redis.client.reconnect
end

Resque::Mailer.argument_serializer = Resque::Mailer::Serializers::ActiveRecordSerializer
