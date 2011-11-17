require 'knockout'
require 'pry' # For easy debugging if necessary using binding.pry

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
