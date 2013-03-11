require 'standalone_validator'
require_relative 'common_rails_options'

class StandaloneValidator
  module NamedValidations
    class ValidatesPresenceOf < StandaloneValidator
      register_as :validates_presence_of

      include CommonRailsOptions

      include_validation do |object, result|
        each_validated_attribute_on(object) do |attribute_name, value|
          if value.blank?
            result.add_violation(attribute_name, :blank)
          end
        end
      end

      def requires_field?(field)
        attributes.include?(field.to_sym)
      end
    end
  end
end
