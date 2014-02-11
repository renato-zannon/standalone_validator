require "spec_helper"
require "standalone_validator"

module StandaloneValidator::NamedValidations
  describe "validates_presence_of" do
    let(:blank_value)     { double(:blank? => true)  }
    let(:non_blank_value) { double(:blank? => false) }

    it "adds a 'blank' violation if the attribute is blank" do
      validator = ValidatesPresenceOf.new(:foo)
      result = validator.violations_of(double(:foo => blank_value))
      expect(result).to_not be_ok
    end

    it "doesn't add the violation if the attribute isn't blank" do
      validator = ValidatesPresenceOf.new(:foo)
      result = validator.violations_of(double(:foo => non_blank_value))
      expect(result).to be_ok
    end

    it "accepts an :if condition that can block the validation" do
      validator = ValidatesPresenceOf.new :foo, :if => :bar

      triggers       = double(:foo => blank_value, :bar => true)
      doesnt_trigger = double(:foo => blank_value, :bar => false)

      result = validator.violations_of(triggers)
      expect(result).to_not be_ok

      result = validator.violations_of(doesnt_trigger)
      expect(result).to be_ok
    end

    it "accepts an :unless condition that can block the validation" do
      validator = ValidatesPresenceOf.new :foo, :unless => :bar

      triggers       = double(:foo => blank_value, :bar => false)
      doesnt_trigger = double(:foo => blank_value, :bar => true)

      result = validator.violations_of(triggers)
      expect(result).to_not be_ok

      result = validator.violations_of(doesnt_trigger)
      expect(result).to be_ok
    end

    it "requires the attributes it was given on construction" do
      validator = ValidatesPresenceOf.new :foo
      expect(validator.requires_field?(:foo, nil)).to be_true
      expect(validator.requires_field?(:bar, nil)).to be_false
    end

    context "if it was given a conditional" do
      it "uses the conditional to decide if a field is required" do
        validator = ValidatesPresenceOf.new(:foo, if: :bar)

        requires       = double(foo: blank_value, bar: true)
        doesnt_require = double(foo: blank_value, bar: false)

        result = validator.requires_field?(:foo, requires)
        expect(result).to be_true

        result = validator.requires_field?(:foo, doesnt_require)
        expect(result).to be_false
      end
    end
  end
end
