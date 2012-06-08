#require 'rails'

module Basics
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/mysql.rake'
    end
  end
end
