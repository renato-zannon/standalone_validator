require 'virtus'

class StandaloneValidator
  class Violation
    include Virtus::ValueObject

    attribute :source_object, Object
    attribute :attribute,     Symbol, :default => :base
    attribute :type,          Symbol, :default => :invalid
    attribute :message,       String, :default => nil
    attribute :options,       Hash,   :default => {}

    def add_to(errors_object)
      errors_object.add(attribute, message || type, options)
      self
    end
  end
end
