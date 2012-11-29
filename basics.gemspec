# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "basics/version"

Gem::Specification.new do |s|
  s.name        = "basics"
  s.version     = Basics::VERSION
  s.authors     = ["Benjamin Huber"]
  s.email       = ["benjamin@rubberandglue.at"]
  s.homepage    = ""
  s.summary     = %q{rubber & glue basics}
  s.description = %q{rubber & glue basics}

  s.rubyforge_project = "basics"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'rvm-capistrano'
  s.add_dependency 'bundler'
  s.add_dependency 'capistrano'
  s.add_dependency 'capistrano_colors'
  s.add_dependency 'capistrano-ext'
  s.add_dependency 'actionpack'

  s.add_development_dependency 'rspec'
end
