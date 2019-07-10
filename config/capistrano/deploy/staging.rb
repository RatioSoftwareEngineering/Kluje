set :domain, 'ec2-52-220-1-138.ap-southeast-1.compute.amazonaws.com'

server fetch(:domain), user: 'ubuntu', roles: %w{web app db}

set :stage, 'staging'
set :application, 'kluje-staging'
set :branch, 'staging' # `git rev-parse --abbrev-ref HEAD`.chomp
set :deploy_to, "/var/proj/#{fetch(:application)}"
