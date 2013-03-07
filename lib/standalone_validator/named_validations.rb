require 'standalone_validator'
require 'standalone_validator/definitions'

class StandaloneValidator
  module NamedValidations
    def self.create(name, klass)
      Definitions.register_validation_factory(name, klass)
    end
  end
end

require 'pathname'
validations = Pathname(__FILE__).parent + "named_validations" + "*.rb"

Dir[validations].each do |validation_file|
  require validation_file
end
