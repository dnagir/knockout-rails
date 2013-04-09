# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
require 'support/global'
require 'support/matchers'
#Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
