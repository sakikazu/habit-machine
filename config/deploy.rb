lock '3.14.1'

require 'dotenv/load'
Dotenv.load

set :application, 'habit-machine'
set :repo_url, ENV['BITBUCKET_URL']

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/usr/local/site/habit-machine'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env config/mysqldump.ini .ruby-version .ruby-gemset}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/cache tmp/sockets tmp/pids vendor/bundle public/upload}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# unicorn
set :unicorn_config_path, "#{current_path}/config/unicorn.conf.rb"
# set :unicorn_pid, 'default'


namespace :deploy do

  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
