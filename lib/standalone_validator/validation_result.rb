require 'standalone_validator/validation_result_builder'
require 'hamster/list'

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

    OK = new({})

    def add_errors_to(errors_object)
      violations.each do |violation|
        violation.add_to(errors_object)
      end

      self
    end

    include Enumerable

    def each(&block)
      violations.each(&block)
    end

    def empty
      violations.empty?
    end

    def ok?
      violations.empty?
    end

    alias_method :valid?, :ok?

    def [](attribute)
      violations.select do |violation|
        violation.attribute == attribute
      end
    end

    def of_type(type)
      subset { |violation| violation.type == type }
    end

    def on_attribute(attribute)
      subset { |violation| violation.attribute == attribute }
    end

  private

    def subset(&block)
      self.class.new(:violations       => violations.select(&block),
                     :validated_object => validated_object)
    end
  end
end
