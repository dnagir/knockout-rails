require 'rails'
require 'active_record/railtie'

module KnockoutRails
  class Engine < Rails::Engine

    initializer "knockout_rails.extend_active_record" do
      ActiveSupport.on_load(:active_record) do
        extend KnockoutRails::ActiveRecord::CoffeeGenerator
      end
    end
  end
end
