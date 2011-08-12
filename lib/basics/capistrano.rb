Capistrano::Configuration.instance(:must_exist).load do
  namespace :deploy do
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
