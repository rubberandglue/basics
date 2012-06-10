Capistrano::Configuration.instance(:must_exist).load do
  require 'rvm/capistrano'
  require 'bundler/setup'
  require 'bundler/capistrano'
  require 'capistrano_colors'
  require 'capistrano/ext/multistage'
  require 'active_support'
  require 'active_support/core_ext/string'

  def prompt_with_default(var, default)
    set var, Proc.new { Capistrano::CLI.ui.ask("#{var} [#{default}] : ") }
    set var, default if eval("#{var.to_s}.empty?")
  end

  set :stages, %w(production staging)
  set :default_stage, "staging"

  set(:app_name) { abort "Please specify the short name of your application, set :app_name, 'foo'" }
  set(:application) { "#{app_name}.rubberandglue.at" }
  set :user, "deploy"

  # RVM
  set :rvm_type, :system

  # Strange rvm behavior
  set :use_sudo, false


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
    { :host_key => "ssh-rsa", :encryption => "blowfish-cbc", :compression => 'zlib', :keys => key_path, :forward_agent => true }
  end

  set(:db_name) { "#{app_name}_#{rails_env}" }
  set :db_admin_user, 'root'
  set(:db_admin_password) { Capistrano::CLI.password_prompt "Enter database password for '#{db_admin_user}': " }
  set(:db_user) { "#{app_name[0..13]}_#{rails_env[0..0]}" }
  set(:db_password) { SecureRandom.hex }

  namespace :db do
    namespace :mysql do
      desc "Setup everything"
      task :setup do
        install
        create_user
        create_database_yml
      end

      task :install, :roles => :db do
        run "#{sudo} apt-get -y update"
        run "#{sudo} apt-get -y install mysql-server mysql-client libmysqlclient-dev"
      end

      task :create_user, :roles => :db, :only => { :primary => true } do
        user_select = <<-SQL.squish
          USE mysql;
          SELECT COUNT(*) FROM user WHERE user = \"#{db_user}\";
        SQL

        user_grant = <<-SQL.squish
          GRANT ALL PRIVILEGES ON #{db_name}.* TO '#{db_user}'@'localhost' IDENTIFIED BY '#{db_password}';
        SQL

        # Check if mysql user already exists
        run "mysql --user=#{db_admin_user} -p --skip-column-names --execute='#{user_select}'" do |channel, stream, data|
          channel.send_data "#{db_admin_password}\n" if stream == :err and data =~ /^Enter password:/
          user_count = data.strip.to_i if stream == :out
        end

        if defined?(user_count) and user_count == 0
          run "mysql --user=#{db_admin_user} -p --execute='#{user_grant}'" do |channel, stream, data|
            channel.send_data "#{db_admin_password}\n" if stream == :err and data =~ /^Enter password:/
          end
        else
          raise 'Mysql user already exists.'
        end
      end

      task :create_database_yml, :roles => :app do
        # Check if database already exists
        file = File.join(shared_path, 'config', 'database.yml')
        run "test ! -r #{file}"

        # Check for different adapters on 1.9
        adapter = rvm_ruby_string.start_with?('1.8') ? 'mysql' : 'mysql2'

        configuration                 = { }
        configuration[rails_env.to_s] = {
          :adapter   => adapter,
          :encoding  => 'utf8',
          :database  => db_name,
          :pool      => 5,
          :username  => db_user,
          :password  => db_password,
          :socket    => '/var/run/mysqld/mysqld.sock',
          :reconnect => false,
          :host      => 'localhost'
        }.stringify_keys

        # Copy config on Server
        put configuration.to_yaml, file
      end
    end
  end

  namespace :deploy do
    task :start do
      ;
    end
    task :stop do
      ;
    end

    desc "Seeding database"
    task :seed, :roles => :web, :except => { :no_release => true } do
      run "cd #{current_path}; RAILS_ENV=#{rails_env} #{rake} db:seed"
    end

    desc "Touching file for Passenger restart"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
    end

    desc "Create asset packages for production"
    task :package_assets, :roles => :web do
      run "cd #{deploy_to}/current && bundle exec jammit"
    end

    desc "Create a symlink for the database config"
    task :symlink_db_config, :roles => :app do
      db_config = "#{shared_path}/config/database.yml"
      run "ln -sf #{db_config} #{release_path}/config/database.yml"
    end
    after 'bundle:install', 'deploy:symlink_db_config'

    desc "Create a symlink for the private upload folder"
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