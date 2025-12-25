namespace :deploy do
  desc "Install JS dependencies"
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute :yarn, "install --silent --no-progress"
      end
    end
  end
end

before "deploy:assets:precompile", "deploy:yarn_install"
