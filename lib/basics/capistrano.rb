Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
    namespace :pending do
      desc "bla"
      task :blubb do
        puts "banane"
      end
    end
  end
end
