Capistrano::Configuration.instance(:must_exist).load do
  require 'capistrano/ext/multistage'

  def prompt_with_default(var, default)
    set var, Proc.new { Capistrano::CLI.ui.ask("#{var} [#{default}] : ")}
    set var, default if eval("#{var.to_s}.empty?")
  end

  set :stages, %w(production development)
  set :default_stage, "development"

  set(:app_name) { abort "Please specify the short name of your application, set :app_name, 'foo'" }
  set(:application) { "#{app_name}.rubberandglue.at" }
  set :user, "deploy"

  # SCM settings
  set(:appdir) { "/projects/#{application}" }
  set :scm, 'git'
  set(:repository) { "git@git.rubberandglue.at:/repositories/#{app_name}.git" }
  set :branch, 'master'
  set :deploy_via, 'remote_cache'
  set :migrate_target, :current
  set(:deploy_to) { appdir }

  # Git settings
  set(:ssh_options) do
    prompt_with_default(:key_path, '~/.ssh/id_rsa')
    {:host_key => "ssh-rsa", :encryption => "blowfish-cbc", :compression => 'zlib', :keys => key_path, :forward_agent => true }
  end
  set :bundle_flags, nil

  namespace :deploy do
    task :start do ; end
    task :stop do ; end

    desc "Touching file for Passenger restart"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end

    desc "Create asset packages for production"
    task :package_assets, :roles => :web do
      run "cd #{deploy_to}/current && bundle exec jammit"
    end

    task :symlink_db_config, :roles => :app do
      db_config = "#{shared_path}/config/database.yml"
      run "ln -sf #{db_config} #{release_path}/config/database.yml"
    end
    after 'deploy:update_code', 'deploy:symlink_db_config'

    task :symlink_private_uploads, :roles => :app do
      shared_upload_path = "#{shared_path}/uploads"
      run "mkdir -p #{shared_upload_path} && chown -R nobody:nogroup #{shared_upload_path} && ln -s #{shared_upload_path} #{release_path}/uploads"
    end
    after 'deploy:update_code', 'deploy:symlink_private_uploads'

    after 'deploy:symlink', 'deploy:cleanup'

    namespace :pending do
      desc "Stat"
      task :stat do
        cmd = source.local.diff(current_revision)
        cmd << " --stat " if scm.to_sym == :git
        system(cmd)
      end
    end
  end
end