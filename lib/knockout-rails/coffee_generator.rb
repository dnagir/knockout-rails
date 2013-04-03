require 'set'

module KnockoutRails
  module ActiveRecord
    module CoffeeGenerator
      def knockout_fields(options = {})
        # For fine-tuning see  Formtastic::Helpers::InputsHelper#default_columns_for_object

        except = (options[:except] || [:created_at, :updated_at]).map { |attr| attr.to_s }
        only = options[:only]
        extra = options[:extra] || []

        # Attributes
        attributes = self.attribute_names

        # Virtual attribues
        self._validators.each do |attribute, attr_validators|
          unless attribute == nil
            attr_validators.each do |validator|
              case validator.kind
                when :acceptance
                  attributes << attribute.to_s

                when :confirmation
                  attributes << attribute.to_s + '_confirmation'
              end
            end
          end
        end

        attributes.delete_if { |k, v| except.include? k }
        attributes = only if only
        attributes += extra

        '@fields ' + attributes.to_set.map { |a| "'#{a}'" }.join(', ')
      end

      def knockout_validations(mapper_options = {})
        model = self

        # USAGE only: {attribute: []} # include all
        # USAGE only: {attribute: :validator_kind}
        # USAGE only: {attribute: [:kind1, :kind2]}
        only = (mapper_options[:only] || {}).each_with_object({}) do |(attr, validators), i|
          i[attr] = (validators.instance_of? Array) ? validators : [validators]
        end

        # USAGE except: {attribute: []} # ignore all validators for attribute
        # USAGE except: {attribute: :validator_kind}
        # USAGE except: {attribute: [:kind1, :kind2]}
        except = (mapper_options[:except] || {}).each_with_object({}) do |(attr, validators), i|
          i[attr] = (validators.instance_of? Array) ? validators : [validators]
        end

        obj_stub = Object.new
        obj_stub.define_singleton_method :class do
          return model
        end
        obj_stub.define_singleton_method :read_attribute_for_validation do |attribute|
          return '%value'
        end

        errors = ActiveModel::Errors.new(obj_stub)

        skipped_validators = []
        ko_validators = []

        model._validators.each do |attribute, attr_validators|
          if attribute == nil
            for validator in attr_validators
              # Custom non-EachValidator validator
              if validator.kind_of? ActiveModel::Validator
                skipped_validators << {kind: validator.kind, options: validator.options}
                # For not-EachValidator custom validators to work one would have to define new validator interface having whole model object as argument
              end
            end
            next
          end

          next if except[attribute] == []
          default_messages = ActiveModel::Errors.new(obj_stub).generate_message(attribute, nil) #=> {:invalid => '..', :too_long => '..'}

          attr_validators.each do |validator|
            next if except[attribute] and except[attribute].include? validator.kind
            next if only.length > 0 and (only[attribute] == nil or not (only[attribute] == [] or only[attribute].include? validator.kind))

            if validator.kind == :block
              skipped_validators << validator.instance_variable_get(:@block).to_s
              next
            end

            options = validator.options
            ko_validator = {kind: validator.kind, attribute: attribute, options: options.select { |k, v| [:message, :allow_nil, :if].include? k }}
            ko_options = ko_validator[:options]
            ko_options[:allow_nil] = true if options[:allow_blank] == true # allow_blank = allow_nil, maybe a bit risky

            ko_options[:validate_on] = options[:on] if options[:on]

            case validator.kind
              when :acceptance
                # allow_nil default to true
                ko_options[:message] ||= default_messages[:accepted]
                ko_options[:accept] = options[:accept] if options[:accept] and options[:accept] != '1' and options[:accept] != true
              #ko_options.merge! options.select{|k,v| k == :accept}

              when :confirmation
                ko_options[:message] ||= default_messages[:confirmation]

              when :exclusion
                ko_options[:message] ||= default_messages[:exclusion]
                ko_options[:within] = options[:in] || options[:within]

              when :inclusion
                ko_options[:message] ||= default_messages[:inclusion]
                ko_options[:within] = options[:in] || options[:within]

              when :format
                if options[:with]
                  ko_options['with'] = json_regexp(options[:with])
                elsif options[:without]
                  ko_options[:without] = json_regexp(options[:without])
                end

              when :length
                max = options[:maximum]
                min = options[:minimum]

                range = options[:in] || options[:within]
                if range
                  min, max = range.begin, range.end
                  max -= 1 if range.exclude_end?
                end

                ko_options[:minimum] = min if min
                ko_options[:maximum] = max if max
                ko_options[:minimum] = ko_options[:maximum] = options[:is] if options[:is]

                ko_options[:message] ||= default_messages[:invalid]
                if not options[:message] # message always takes precedence, we don't need others
                  custom_msg = ko_options[:messages] = {}
                  [:wrong_length, :too_short, :too_long].each do |msg_key|
                    custom_msg[msg_key] = options[msg_key] || default_messages[msg_key]
                    # || errors.generate_message(attribute, msg_key, {count: '%count' }) # safer solution, one message per time
                  end
                end

                if options[:tokenizer]
                  skipped_validators << ko_validator
                  next
                end

              when :numericality
                msg_fields = [:greater_than, :greater_than_or_equal_to, :equal_to, :less_than, :less_than_or_equal_to, :odd, :even]
                ko_options.merge! options.select { |k, v| (msg_fields + [:only_integer]).include? k }

                if options[:message] # message always takes precedence, we don't need others
                  ko_options[:messages] = {}
                else
                  ko_options[:messages] = default_messages.select { |k, v| msg_fields.include? k and options.include? k or [:not_a_number, :not_an_integer].include? k }
                end

              when :presence
                ko_options[:message] = default_messages[:blank] unless ko_options[:message]

              else
                # Maybe custom EachValidator? Let it pass
            end

            # add validator
            unless options[:if] or options[:unless]
              ko_validators << ko_validator
            else
              skipped_validators << ko_validator
            end
          end
        end


        coffee_str = ''
        newline = mapper_options[:newline] ? "\n" : ''

        ko_validators.each do |validator|
          attr_str = validator[:attribute] ? "'#{validator[:attribute]}', " : ''
          coffee_str += "@#{validator[:kind]} #{attr_str}#{validator[:options].to_json}; " + newline
        end

        unless skipped_validators.empty? or not Rails.env.development?
          for validator in skipped_validators
            if validator.instance_of? Hash
              coffee_str += '# Skipped: ' + "@#{validator[:kind]} '#{validator[:attribute]}'#{validator[:options].to_json}; " + newline
            else
              coffee_str += '# Skipped: ' + validator.to_s + newline
            end
          end
        end

        return coffee_str
      end

      private
      # Taken from ActionDispatch::Routing::RouteWrapper
      def json_regexp regexp
        str = regexp.inspect.
            sub('\\A', '^').
            sub('\\Z', '$').
            sub('\\z', '$').
            sub(/^\//, '').
            sub(/\/[a-z]*$/, '').
            gsub(/\(\?#.+\)/, '').
            gsub(/\(\?-\w+:/, '(').
            gsub(/\s/, '')
        Regexp.new(str).source
      end
    end
  end
end