require "spec_helper"
require "standalone_validator"

describe "validates_presence_of" do
  let(:validator_class) do
    StandaloneValidator.create do
      validates_presence_of :foo
    end
  end

  let(:validator) { validator_class.new }

  let(:blank_value)     { stub(:blank? => true)  }
  let(:non_blank_value) { stub(:blank? => false) }

  it "adds a 'blank' violation if the attribute is blank" do
    result = validator.violations_of(stub(:foo => blank_value))
    expect(result).to_not be_ok
  end

  it "doesn't add the violation if the attribute isn't blank" do
    result = validator.violations_of(stub(:foo => non_blank_value))
    expect(result).to be_ok
  end
end
