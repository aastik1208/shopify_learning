lock '3.16.0'

set :application, 'advance_promocode'
set :repo_url, 'git@github.com:socialimprints/advance_promo_code_shopify_app.git'
set :deploy_to, '/var/www/apps/advance_promocode'
set :keep_releases, 5
set :format, :pretty
set :log_level, :debug
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/packs', 'node_modules')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/application.yml', 'config/storage.yml', 'config/master.key')
set :passenger_restart_with_touch, true
set :default_env, { 'NODE_ENV' => 'production' }

set :rbenv_type, :user # :user or :system, depends on your rbenv setup
set :rbenv_ruby, File.read('.ruby-version').strip

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :ssh_options, {
  forward_agent: true
}

namespace :deploy do

  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        execute :touch, release_path.join('tmp/restart.txt')
      end
    end
  end

end

namespace :delayed_job do

  desc 'Restart delayed job'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :'bin/delayed_job', :restart
        end
      end
    end
  end

end

after 'deploy:publishing', 'deploy:restart'
after "deploy:restart", "delayed_job:restart"

set :whenever_environment, -> { fetch(:rails_env) }
#set :whenever_command, 'bundle exec whenever'
