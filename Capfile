set :deploy_config_path, 'config/capistrano/deploy.rb'
set :stage_config_path, 'config/capistrano/deploy'

require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/scm/git'
require 'whenever/capistrano'
# require 'rvm1/capistrano3'
require 'capistrano/rvm'
require 'capistrano/bundler'
# require 'capistrano/rails'
install_plugin Capistrano::SCM::Git

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
