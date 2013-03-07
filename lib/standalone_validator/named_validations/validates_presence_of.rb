require 'standalone_validator'

module NamedValidations
  class ValidatesPresenceOf < StandaloneValidator
    register_as :validates_presence_of

    def initialize(attribute_name)
      @attribute_name = attribute_name
    end

    include_validation do |object, result|
      value = object.send(attribute_name)

      if value.blank?
        result.add_violation(attribute_name, :blank)
      end
    end

  private

    attr_reader :attribute_name
  end
end
