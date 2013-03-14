require 'standalone_validator'
require_relative 'common_rails_options'

class StandaloneValidator
  module NamedValidations
    class ValidatesNumericalityOf < StandaloneValidator
      register_as :validates_numericality_of

      # Stolen from ActiveSupport
      INTEGER_REGEX = /\A[+-]?\d+\Z/.freeze

      include CommonRailsOptions

      COMPARISON_OPTIONS = {
        :greater_than             => lambda { |base, x| x >  base },
        :greater_than_or_equal_to => lambda { |base, x| x >= base },
        :equal_to                 => lambda { |base, x| x == base },
        :less_than                => lambda { |base, x| x <  base },
        :less_than_or_equal_to    => lambda { |base, x| x <= base },
      }.freeze

      include_validation do |object, result|
        each_validated_attribute_on(object) do |attribute_name, value|
          next if ignore_value?(value)

          unless coercible_to_number?(value)
            result.add_violation(attribute_name, :not_a_number)
          end

          each_comparison_violation_of(value) do |violation_name|
            result.add_violation(attribute_name, violation_name)
          end
        end
      end

    private

      def each_comparison_violation_of(value)
        selected_comparisons.each do |option, (base, check)|
          yield(option) unless check.call(base, value)
        end

        self
      end

      def selected_comparisons
        return @selected_comparisons if defined?(@selected_comparisons)

        passed = COMPARISON_OPTIONS.keys & options.keys
        @selected_comparisons = passed.each_with_object({}) do |option, result|
          result[option] = [options[option], COMPARISON_OPTIONS[option]]
        end
      end

      def coercible_to_number?(value)
        if options[:only_integer]
          is_integer?(value)
        else
          is_number?(value)
        end
      end

      def ignore_value?(value)
        if options[:allow_nil]
          value.nil?
        elsif options[:allow_blank]
          value.blank?
        else
          false
        end
      end

      def is_integer?(value)
        value.is_a?(Integer) || value.to_s =~ INTEGER_REGEX
      end

      def is_number?(value)
        return true if is_integer?(value)

        !!Kernel.Float(value)
      rescue ArgumentError, TypeError
        false
      end
    end
  end
end
