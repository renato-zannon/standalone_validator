require 'standalone_validator/validation_result'
require 'standalone_validator/violation'

class StandaloneValidator
  class ValidationResultBuilder
    attr_writer :validated_object

    def merge_result(result)
      combined_results << result
      self
    end

    def add_violation(attribute_name, violation_type_or_message)
      creation_attributes = {
        :attribute     => attribute_name.to_sym,
        :source_object => validated_object
      }

      if violation_type_or_message.kind_of?(Symbol)
        creation_attributes[:type] = violation_type_or_message
      else
        creation_attributes[:message] = violation_type_or_message
      end

      push_violation(Violation.new(creation_attributes))
      self
    end

    def result
      ValidationResult.new(
        :validated_object => validated_object,
        :violations       => all_violations
      )
    end

  private
    attr_reader :validated_object

    def all_violations
      combined_results.inject(violations) do |violations_list, subresult|
        violations_list.append(subresult.violations)
      end
    end

    def combined_results
      @combined_results ||= []
    end

    def push_violation(violation)
      @violations = violations.cons(violation)
    end

    def violations
      @violations ||= Hamster.list
    end
  end
end
