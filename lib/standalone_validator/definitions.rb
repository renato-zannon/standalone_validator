require 'backports/basic_object'

class StandaloneValidator
  class ValidationNotFoundException < Exception
    def initialize(validation_name)
      super("No such validation: #{validation_name.inspect}")
    end
  end

  class Definitions
    def self.register_validation_factory(name, validation_factory)
      @registry ||= {}
      @registry[name.to_sym] = validation_factory
      self
    end

    def self.lookup_validation_factory(name)
      @registry ||= {}
      @registry[name.to_sym]
    end

    def initialize(klass, &block)
      @klass = klass
      instance_eval(&block)
    end

    def apply
      collected_validations.each do |validation|
        klass.add_validation(validation)
      end

      added_methods.each do |method_name|
        method_body = method(method_name).to_proc
        klass.send(:define_method, method_name, &method_body)
      end

      self
    end

    def include_validation(validation_or_validation_class = nil, *args, &block)
      if validation_or_validation_class.respond_to?(:new)
        validation = validation_or_validation_class.new(*args, &block)
      elsif validation_or_validation_class.nil?
        validation = lambda do |object|
          ValidationResult.build_for(object) do |result|
            block.call(object, result)
          end
        end
      else
        validation = validation_or_validation_class
      end

      collected_validations << validation
      self
    end

    alias_method :include_validations_from, :include_validation

    def singleton_method_added(method_name)
      added_methods << method_name
    end

    def method_missing(method_name, *args, &block)
      if klass.respond_to?(method_name)
        klass.send(method_name, *args, &block)
      elsif factory = Definitions.lookup_validation_factory(method_name.to_sym)
        collected_validations << factory.call(*args, &block)
        self
      else
        raise ValidationNotFoundException.new(method_name)
      end
    end

    def respond_to?(method)
      method = method.to_sym

      if methods.map(&:to_sym).include?(method) || klass.respond_to?(method)
        true
      else
        Definitions.lookup_validation_factory(method) != nil
      end
    end

  private

    attr_reader :collected_validations, :klass

    def added_methods
      @added_methods ||= []
    end

    def collected_validations
      @collected_validations ||= []
    end
  end
end
