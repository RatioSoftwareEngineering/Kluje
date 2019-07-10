set :domain, 'ec2-52-76-47-128.ap-southeast-1.compute.amazonaws.com'

server fetch(:domain), user: 'ubuntu', roles: %w{web app db}

set :stage, 'production'
set :application, 'kluje-production'
set :branch, 'master'
set :deploy_to, "/var/proj/#{fetch(:application)}"

after :deploy, "deploy:tags:create" unless fetch(:skip_tag, false)
