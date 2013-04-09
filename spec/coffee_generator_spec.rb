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

    def validations_for name, mapper_options = {}, &block
      define_class(name, &block).knockout_validations mapper_options
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

  it 'skip uniqueness' do
    ko_validators, skipped_validators = validations_for 'UniquenessValidatedModel' do
      validates :fld1, uniqueness: true
    end

    fld1_uniq = kov :uniqueness, :fld1

    ko_validators.should_not include(fld1_uniq)
    skipped_validators.should include(fld1_uniq)
  end

  it 'filter validations: only' do
    # USAGE only: {attribute: []} # include all
    # USAGE only: {attribute: :validator_kind}
    # USAGE only: {attribute: [:kind1, :kind2]}
    filtered_only_kovs, skipped_validators = validations_for 'FilterOnlyValidationsModel', only: {fld1: [], fld2: :presence, fld3: 'presence', fld4: [:presence]} do
      validates :fld1, presence: true, numericality: true
      validates :fld2, presence: true, numericality: true
      validates :fld3, presence: true, numericality: true
      validates :fld4, presence: true, numericality: true
      validates :fld5, presence: true, numericality: true
    end

    filtered_only_kovs.should include(kov(:presence, :fld1, {:message => "can't be blank"}))
    filtered_only_kovs.should include(kov(:numericality, :fld1, {messages: {:not_a_number => "is not a number", :not_an_integer => "must be an integer"}}))
    filtered_only_kovs.should include(kov(:presence, :fld2, {:message => "can't be blank"}))
    filtered_only_kovs.should include(kov(:presence, :fld3, {:message => "can't be blank"}))
    filtered_only_kovs.should include(kov(:presence, :fld4, {:message => "can't be blank"}))
    filtered_only_kovs.size.should eq(5)
  end

  it 'filter validations: except' do
    # USAGE except: {attribute: []} # ignore all validators for attribute
    # USAGE except: {attribute: :validator_kind}
    # USAGE except: {attribute: [:kind1, :kind2]}
    filtered_except_kovs, skipped_validators = validations_for 'FilterExceptValidationsModel', except: {fld1: [], fld2: :numericality, fld3: 'numericality', fld4: [:numericality]} do
      validates :fld1, presence: true, numericality: true
      validates :fld2, presence: true, numericality: true
      validates :fld3, presence: true, numericality: true
      validates :fld4, presence: true, numericality: true
      validates :fld5, presence: true, numericality: true
    end

    filtered_except_kovs.should include(kov(:presence, :fld2, {:message => "can't be blank"}))
    filtered_except_kovs.should include(kov(:presence, :fld3, {:message => "can't be blank"}))
    filtered_except_kovs.should include(kov(:presence, :fld4, {:message => "can't be blank"}))
    filtered_except_kovs.should include(kov(:presence, :fld5, {:message => "can't be blank"}))
    filtered_except_kovs.should include(kov(:numericality, :fld5, {messages: {:not_a_number => "is not a number", :not_an_integer => "must be an integer"}}))
    filtered_except_kovs.size.should eq(5)
  end
end

