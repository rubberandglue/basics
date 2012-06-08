desc "Explaining what the task does"
namespace :db do
  namespace :mysql do
    desc 'Setup MySQL'
    task :setup do
      file = File.join(Rails.root, 'config', 'database.yml')
      if File.exist?(file)
        puts "database.yml already exists"
        return
      end

      app_name = Rails.application.class.parent_name.downcase
      db_name  = "#{app_name}_#{Rails.env}"
      # Range 0..0 for Ruby 1.8 because 0 would be ascii
      # TODO: db_user von capistrano √ºbergeben
      db_user  = "#{app_name[0..13]}_#{Rails.env[0..0]}"
      db_pass  = SecureRandom.hex

      configuration            = { }
      configuration[Rails.env] = {
          :adapter   => 'mysql2',
          :encoding  => 'utf8',
          :database  => db_name,
          :pool      => 5,
          :username  => db_user,
          :password  => db_pass,
          :socket    => '/var/run/mysqld/mysqld.sock',
          :reconnect => false,
          :host      => 'localhost'
      }.stringify_keys

      File.open(file, 'w') do |f|
        YAML.dump(configuration, f)
      end
    end
  end
end
