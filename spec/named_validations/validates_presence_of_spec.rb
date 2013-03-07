require "spec_helper"
require "standalone_validator"

module StandaloneValidator::NamedValidations
  describe "validates_presence_of" do
    let(:blank_value)     { stub(:blank? => true)  }
    let(:non_blank_value) { stub(:blank? => false) }

    it "adds a 'blank' violation if the attribute is blank" do
      validator = ValidatesPresenceOf.new(:foo)
      result = validator.violations_of(stub(:foo => blank_value))
      expect(result).to_not be_ok
    end

    it "doesn't add the violation if the attribute isn't blank" do
      validator = ValidatesPresenceOf.new(:foo)
      result = validator.violations_of(stub(:foo => non_blank_value))
      expect(result).to be_ok
    end

    it "accepts an :if condition that can block the validation" do
      validator = ValidatesPresenceOf.new :foo, :if => :bar

      triggers       = stub(:foo => blank_value, :bar => true)
      doesnt_trigger = stub(:foo => blank_value, :bar => false)

      result = validator.violations_of(triggers)
      expect(result).to_not be_ok

      result = validator.violations_of(doesnt_trigger)
      expect(result).to be_ok
    end

    it "accepts an :unless condition that can block the validation" do
      validator = ValidatesPresenceOf.new :foo, :unless => :bar

      triggers       = stub(:foo => blank_value, :bar => false)
      doesnt_trigger = stub(:foo => blank_value, :bar => true)

      result = validator.violations_of(triggers)
      expect(result).to_not be_ok

      result = validator.violations_of(doesnt_trigger)
      expect(result).to be_ok
    end
  end
end
