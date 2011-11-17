# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knockout-rails/version"

Gem::Specification.new do |s|
  s.name        = "knockout-rails"
  s.version     = KnockoutRails::VERSION
  s.authors     = ["Dmytrii Nagirniak"]
  s.email       = ["dnagir@gmail.com"]
  s.homepage    = "http://github.com/dnagir/knockout-rails"
  s.summary     = %q{Knockout.JS library for Rails Assets Pipeline with convenient Backbone/Spine-like Rails extensions.}
  s.description = %q{Include the knockout.js and some of its extensions so you can pick what you need. Adds the support for models and interation with the Rails backend.}

  s.rubyforge_project = "knockout-rails"

  s.add_dependency             'sprockets', '>= 2.0.0'
  s.add_dependency             'execjs'
  s.add_dependency             'jquery-rails'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rails', '>= 3.1.1'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
