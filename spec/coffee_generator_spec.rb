require 'spec_helper'
#require 'active_record'

module KnockoutRails
  module TestExtensions
    # Knockout-validator description
    def kov(kind, attribute, options = {})
      {kind: kind, attribute: attribute, options: options}
    end

    def define_class name, &block
      klazz = Class.new do
        include ::ActiveRecord::Validations
        extend KnockoutRails::ActiveRecord::CoffeeGenerator

        instance_eval &block
      end

      Object.const_set(name.classify, klazz)
      klazz
    end

    def validations_for name, &block
      define_class(name, &block).knockout_validations
    end
  end
end

describe 'Generate validations' do
  include KnockoutRails::TestExtensions

  it 'presence' do
    ko_validators, skipped_validators = validations_for 'PresenceValidatedModel' do
      validates_presence_of :fld1
    end

    ko_validators.should include(kov :presence, :fld1, {message: "can't be blank"})
  end

  it 'uniqueness' do
    ko_validators, skipped_validators = validations_for 'UniquenessValidatedModel' do
      validates :fld1, uniqueness: true
    end

    fld1_uniq = kov :uniqueness, :fld1

    ko_validators.should_not include(fld1_uniq)
    skipped_validators.should include(fld1_uniq)
  end
end

