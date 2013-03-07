require 'standalone_validator/validations'

class StandaloneValidator
  Validations.create :validates_presence_of do

    def initialize(attribute_name)
      @attribute_name = attribute_name
    end

    def call(object)
      value = object.send(attribute_name)

      if value.blank?
        ValidationResult.build_for(object) do |result|
          result.add_violation(attribute_name, :blank)
        end
      else
        ValidationResult::OK
      end
    end

  private

    attr_reader :attribute_name
  end
end
