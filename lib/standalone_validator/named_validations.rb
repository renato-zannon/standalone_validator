require 'standalone_validator'
require 'standalone_validator/definitions'
require 'backports/rails'

class StandaloneValidator
  module NamedValidations
    def self.create(name, &block)
      klass = StandaloneValidator.create(&block)

      constant_name = name.to_s.camelize
      NamedValidations.const_set(constant_name, klass)

      Definitions.register_validation_factory(name, klass)
    end
  end
end

require 'pathname'
validations = Pathname(__FILE__).parent + "named_validations" + "*.rb"

Dir[validations].each do |validation_file|
  require validation_file
end
