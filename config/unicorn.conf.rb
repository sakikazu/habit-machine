app_root = File.expand_path("../..", __FILE__)
listen "#{app_root}/tmp/sockets/unicorn.sock", :backlog => 1024
pid "tmp/pids/unicorn.pid"

# worker_processes 2

# ダウンタイムなくす
preload_app true

stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"
  unless old_pid == server.pid
    begin
      # SIGTTOU た?と worker_processes か?多いときおかしい気か?する
      Process.kill :QUIT, File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
