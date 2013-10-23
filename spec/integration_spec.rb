require 'spec_helper'
require 'standalone_validator'

describe "core features" do
  let(:valid_object)   { double(:valid? => true) }
  let(:invalid_object) { double(:valid? => false) }

  it "accepts inline lambdas via 'include_validation'" do
    validator_class = StandaloneValidator.create do
      include_validation do |object, result|
        unless object.valid?
          result.add_violation(:base, "is invalid")
        end
      end
    end

    validator = validator_class.new

    result = validator.violations_of(valid_object)
    expect(result).to be_ok

    result = validator.violations_of(invalid_object)
    expect(result).to_not be_ok
  end

  specify "the methods added to the class are accessible inside the lambda" do
    validator_class = StandaloneValidator.create do
      include_validation do |object, result|
        unless valid?(object)
          result.add_violation(:base, "is invalid")
        end
      end

      def valid?(object)
        object.valid?
      end
    end

    validator = validator_class.new

    result = validator.violations_of(valid_object)
    expect(result).to be_ok

    result = validator.violations_of(invalid_object)
    expect(result).to_not be_ok
  end

  specify "initialization options can be accepted by defining a constructor" do
    validator_class = StandaloneValidator.create do
      def initialize(bias)
        @bias = bias
      end

      include_validation do |object, result|
        unless @bias
          result.add_violation(:base, "is invalid")
        end
      end
    end

    biased_validator = validator_class.new(true)
    result = biased_validator.violations_of(invalid_object)
    expect(result).to be_ok

    biased_validator = validator_class.new(false)
    result = biased_validator.violations_of(valid_object)
    expect(result).to_not be_ok
  end
end
