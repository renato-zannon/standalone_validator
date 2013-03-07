require 'standalone_validator/validation_result_builder'
require 'hamster'

class StandaloneValidator
  class ValidationResult
    def self.build_for(object, &block)
      builder = ValidationResultBuilder.new
      builder.validated_object = object

      if block.arity == 1
        block.call(builder)
      else
        builder.instance_eval(&block)
      end

      builder.result
    end

    attr_reader :validated_object, :violations

    def initialize(attributes)
      @validated_object = attributes.fetch(:validated_object) { nil }

      violations  = attributes.fetch(:violations) { Hamster::EmptyList }
      @violations = violations.to_list
    end

    def add_errors_to(errors_object)
      violations.each do |violation|
        violation.add_to(errors_object)
      end

      self
    end

    def ok?
      violations.empty?
    end

    alias_method :any?, :ok?

    def has_violations?
      not ok?
    end

    OK = new({})
  end
end
