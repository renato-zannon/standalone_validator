require 'standalone_validator/definitions'

class StandaloneValidator
  module Validations
    def self.create(name, &block)
      klass = Class.new(Validation, &block)
      Definitions.register_validation_factory(name, klass)
    end
  end

  class Validation
    class << self
      alias_method :call, :new
    end
  end
end

require 'pathname'
validations = Pathname(__FILE__).parent + "validations" + "*.rb"

Dir[validations].each do |validation_file|
  require validation_file
end
