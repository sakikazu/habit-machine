lock '3.19.2'

require 'dotenv/load'
Dotenv.load

set :application, 'habit-machine'
set :repo_url, ENV['BITBUCKET_URL']

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/ubuntu/web/habit-machine'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/cache tmp/sockets tmp/pids bundle public/upload storage}
# NOTE: for capistrano-bundler config file (see: https://github.com/capistrano/bundler)
append :linked_dirs, '.bundle'

set :default_env, {
  # NOTE: Node.jsとOpenSSLのバージョンの互換性が合わないために必要になっている環境変数
  'NODE_OPTIONS' => '--openssl-legacy-provider',
  # task :set_ruby_version のためのASDFの環境変数
  'PATH' => "/home/ubuntu/.asdf/shims:/home/ubuntu/.asdf/bin:$PATH",
  'ASDF_DIR' => "/home/ubuntu/.asdf"
}

# Default value for keep_releases is 5
# set :keep_releases, 5

# TODO: capistrano-asdfがなぜか current/.tool-versionsではなく/home/ubuntu/.tool-versionsを読み込んでしまうため、下記対応
# deployログを見ると `shared/asdf-wrapper asdf current` がポイントっぽいので、asdf-wrapperを読めばわかるかもしれない
namespace :deploy do
  task :set_ruby_version do
    on roles(:app) do
      within release_path do
        execute :asdf, "install"
      end
    end
  end
end
before "deploy:updated", "deploy:set_ruby_version"
