require 'hamster/hash'
require 'hamster/vector'

class StandaloneValidator
  class ValidationNotFoundException < Exception
    def initialize(validation_name)
      super("No such validation: #{validation_name.inspect}")
    end
  end

  module Definitions
    module_function

    def register_validation_factory(name, validation_factory)
      @registry = registry.put(name.to_sym, validation_factory)
      listeners.each do |listener|
        listener.call(name, validation_factory)
      end
      self
    end

    def lookup_validation_factory(name)
      registry[name.to_sym]
    end

    def on_validation_registered(callable = nil, &block)
      if block_given?
        @listeners = listeners.add(block)
      else
        @listeners = listeners.add(block)
      end

      self
    end

    def coerce_to_validation(validation_or_validation_class = nil, *args, &block)
      if validation_or_validation_class.respond_to?(:new)
        validation_or_validation_class.new(*args, &block)
      elsif validation_or_validation_class.nil? && block_given?
        lambda { |object|
          ValidationResult.build_for(object) do |result|
            instance_exec(object, result, &block)
          end
        }
      else
        validation_or_validation_class
      end
    end

    def registry
      @registry ||= Hamster.hash
    end

    def listeners
      @listeners ||= Hamster.vector
    end
  end
end
