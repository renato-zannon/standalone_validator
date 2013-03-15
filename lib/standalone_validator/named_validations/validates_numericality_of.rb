require 'standalone_validator'
require_relative 'common_rails_options'

class StandaloneValidator
  module NamedValidations
    class ValidatesNumericalityOf < StandaloneValidator
      register_as :validates_numericality_of

      include CommonRailsOptions

      # Stolen from ActiveSupport
      INTEGER_REGEX = /\A[+-]?\d+\Z/.freeze

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

          begin
            coerced_value = coerce_to_number(value)

            each_comparison_violation_of(coerced_value) do |violation_name|
              result.add_violation(attribute_name, violation_name)
            end
          rescue TypeError, ArgumentError
            result.add_violation(attribute_name, :not_a_number)
          end
        end
      end

    private

      def ignore_value?(value)
        if options[:allow_nil]
          value.nil?
        elsif options[:allow_blank]
          value.blank?
        else
          false
        end
      end

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

      def coerce_to_number(value)
        if options[:only_integer]
          raise ArgumentError unless value.to_s =~ INTEGER_REGEX
          Kernel.Integer(value)
        else
          Kernel.Float(value)
        end
      end

    end
  end
end
