workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

preload_app!

rackup DefaultRackup if defined?(DefaultRackup)
port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

on_worker_boot do
  ActiveRecord::Base.establish_connection
end

# Rails.envはロード前なので使えない
if ENV.fetch("RAILS_ENV") == "production"
  bind 'unix:///home/ubuntu/web/habit-machine/shared/tmp/sockets/puma.sock'
  pidfile '/home/ubuntu/web/habit-machine/shared/tmp/pids/puma.pid'
  state_path '/home/ubuntu/web/habit-machine/shared/tmp/pids/puma.state'
end
