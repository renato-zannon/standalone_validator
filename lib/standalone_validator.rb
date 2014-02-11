require 'backports'
require 'hamster/set'

require 'standalone_validator/version'

require 'standalone_validator/definitions'
require 'standalone_validator/validation_result_builder'

class StandaloneValidator
  class << self
    Definitions.on_validation_registered do |name, validation|
      define_method(name) do |*args, &block|
        include_validation(validation, *args, &block)
      end
    end

    def create(&block)
      Class.new(StandaloneValidator, &block)
    end

    def register_as(name)
      NamedValidations.create(name, self)
    end

    def validations
      return @validations if defined?(@validations)

      if superclass.kind_of?(StandaloneValidator)
        @validations = superclass.validations
      else
        @validations = Hamster.set
      end
    end

    def required_fields
      return @required_fields if defined?(@required_fields)

      if superclass.kind_of?(StandaloneValidator)
        @required_fields = superclass.required_fields
      else
        @required_fields = Hamster.set
      end
    end

  private

    def include_validation(*args, &block)
      validation = Definitions.coerce_to_validation(*args, &block)
      @validations = validations.add(validation)
    end

    def requires_field(name)
      @required_fields = required_fields.add(name.to_sym)
    end
  end

  require 'standalone_validator/named_validations'

  def violations_of(object, appliable_validations = validations)
    builder = StandaloneValidator::ValidationResultBuilder.new
    builder.validated_object = object

    appliable_validations.each do |validation|
      if validation.respond_to?(:to_proc)
        result = instance_exec(object, &validation)
      else
        result = validation.call(object)
      end

      builder.merge_result(result)
    end

    builder.result
  end

  alias_method :call, :violations_of

  def add_errors_to(object)
    validation_result = violations_of(object)
    validation_result.add_errors_to(object.errors)
    validation_result
  end

  def requires_field?(field, object)
    return true if self.class.required_fields.include?(field.to_sym)

    validations.any? do |validation|
      if validation.respond_to?(:requires_field?)
        validation.requires_field?(field, object)
      end
    end
  end

private

  def validations
    self.class.validations
  end
end
