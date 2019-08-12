# config valid only for Capistrano 3.1
lock '3.8.1'

set :repo_url, 'git@github.com:RatioSoftwareEngineering/Kluje.git'
set :user, 'ubuntu'

set :rvm, File.join('/home', fetch(:user), '.rvm', 'bin', 'rvm')
set :rvm_ruby_string, `cat .ruby-version`

set :linked_files, %w{config/application.yml config/database.yml config/secrets.yml config/newrelic.yml config/twilio.yml config/redis.yml public/robots.txt}
set :linked_dirs, %w{public/assets log certs tmp/cache}

set :rvm_type, :system
set :keep_releases, 5

set :ssh_options, {
                   keys: [File.join(ENV['HOME'],'.ssh','id_rsa')],
                   forward_agent: true
                   }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
#      within release_path do
#        execute :rake, 'cache:clear'
#      end
    end
  end

  namespace :tags do
    desc "Automatically create a git tag in the form 'deploy_yyyy_mm_dd_hh_mm'"
    task :create do
      tag_name = Time.now.strftime("%Y-%m-%d_%H%M")
      ref = `git ls-remote git@github.com:KlujePteLtd/kluje.git refs/heads/#{fetch(:branch)} | awk '{print $1}'`.chomp
      system "git tag -a -m 'Deployment on #{fetch(:stage)}' #{tag_name} #{ref}"
      system "git push origin #{tag_name}"
      if $? != 0
        raise "Pushing tag to origin failed"
      end
    end
  end

  namespace :resque do
    desc "Restart resque workers"
    task :restart do
      on roles(:app) do
        within release_path do
          execute "cd #{release_path} && #{SSHKit.config.command_map[:rake]} resque:restart_workers QUEUE='*' RACK_ENV=#{fetch(:stage)}  >> #{fetch(:deploy_to)}/shared/log/resque.log 2>&1 &"
          execute "cd #{release_path} && if ps aux | grep [r]esque-scheduler > /dev/null; then echo \"resque-scheduler running\"; else #{SSHKit.config.command_map[:rake]} resque:scheduler RACK_ENV=#{fetch(:stage)} BACKGROUND=yes >> #{fetch(:deploy_to)}/shared/log/resque.log 2>&1; fi"
        end
      end
    end
  end

  namespace :db do
    desc "Run db migrations"
    task :migrate do
      on roles(:db) do
        within release_path do
          execute "cd #{release_path} && #{SSHKit.config.command_map[:rake]} db:migrate RAILS_ENV=#{fetch(:stage)} >> #{fetch(:deploy_to)}/shared/log/db.log 2>&1 &"
        end
      end
    end
  end
end

namespace :assets do
  desc "Precompile assets"
  task :precompile do
    on roles(:app) do
      within release_path do
        execute "cd #{release_path} && #{SSHKit.config.command_map[:rake]} assets:precompile RAILS_ENV=#{fetch(:stage)}"
      end
    end
  end
end

after "deploy:restart", "deploy:resque:restart"
after "deploy:restart", "deploy:db:migrate"
before "deploy:restart", "assets:precompile"
before 'whenever:update_crontab', 'whenever:clear_crontab'