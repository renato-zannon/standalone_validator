require "spec_helper"
require "ostruct"
require "standalone_validator"

module StandaloneValidator::NamedValidations
  describe "validates_numericality_of" do
    let(:object)    { OpenStruct.new }
    let(:validator) { ValidatesNumericalityOf.new(:foo) }

    it "adds a 'not_a_number' violation if the attribute isn't a number" do
      object.foo = "not a number"
      violations = validator.violations_of(object).on_attribute(:foo)
      expect(violations.of_type(:not_a_number)).to_not be_empty
    end

    it "doesn't add the violation if the attribute is a number" do
      object.foo = 10
      violations = validator.violations_of(object).on_attribute(:foo)
      expect(violations.of_type(:not_a_number)).to be_empty
    end

    it "accepts strings that represent integer numbers" do
      object.foo = "10"
      violations = validator.violations_of(object).on_attribute(:foo)
      expect(violations.of_type(:not_a_number)).to be_empty
    end

    describe "the :only_integer option" do
      context "when the :only_integer option is set to true" do
        let(:validator) { ValidatesNumericalityOf.new(:foo, :only_integer => true) }

        it "does not accept floats" do
          object.foo = 10.5
          violations = validator.violations_of(object).on_attribute(:foo)
          expect(violations.of_type(:not_a_number)).to_not be_empty
        end

        it "does not accept strings that represent floating numbers" do
          object.foo = "10.5"
          violations = validator.violations_of(object).on_attribute(:foo)
          expect(violations.of_type(:not_a_number)).to_not be_empty
        end
      end

      context "when the :only_integer is not set" do
        let(:validator) { ValidatesNumericalityOf.new(:foo) }

        it "accepts floats" do
          object.foo = 10.5
          violations = validator.violations_of(object).on_attribute(:foo)
          expect(violations.of_type(:not_a_number)).to be_empty
        end

        it "accepts strings that represent floating numbers" do
          object.foo = "10.5"
          violations = validator.violations_of(object).on_attribute(:foo)
          expect(violations.of_type(:not_a_number)).to be_empty
        end
      end
    end

    describe "the :allow_blank option" do
      context "when the :allow_blank option is set" do
        let(:validator) { ValidatesNumericalityOf.new(:foo, :allow_blank => true) }

        it "ignores 'blank' values" do
          object.foo = double(:blank? => true, :to_f => 0)
          violations = validator.violations_of(object).on_attribute(:foo)
          expect(violations).to be_empty
        end
      end

      context "when the :allow_blank option is not set" do
        let(:validator) { ValidatesNumericalityOf.new(:foo) }

        it "does not ignore 'blank' values" do
          object.foo = double(:blank? => true, :to_f => 0)
          violations = validator.violations_of(object).on_attribute(:foo)
          expect(violations.of_type(:not_a_number)).to_not be_empty
        end
      end
    end

    describe "the :allow_nil option" do
      context "when the :allow_nil option is set" do
        let(:validator) { ValidatesNumericalityOf.new(:foo, :allow_nil => true) }

        it "ignores nil values" do
          object.foo = nil
          violations = validator.violations_of(object).on_attribute(:foo)
          expect(violations).to be_empty
        end
      end

      context "when the :allow_blank option is not set" do
        let(:validator) { ValidatesNumericalityOf.new(:foo) }

        it "does not ignore 'nil' values" do
          object.foo = nil
          violations = validator.violations_of(object).on_attribute(:foo)
          expect(violations.of_type(:not_a_number)).to_not be_empty
        end
      end
    end

    compared_value = v = 1

    comparison_options = {
      :greater_than =>             {:ok => v + 1,      :not_ok => [v, v - 1]    },
      :greater_than_or_equal_to => {:ok => [v, v + 1], :not_ok => v - 1         },
      :equal_to =>                 {:ok => v,          :not_ok => [v - 1, v + 1]},
      :less_than =>                {:ok => v - 1,      :not_ok => [v, v + 1]    },
      :less_than_or_equal_to =>    {:ok => [v, v - 1], :not_ok => v + 1         },
    }.freeze

    comparison_options.each do |option_name, comparisons|
      describe "when '#{compared_value}' is given on :#{option_name}" do
        let(:validator) do
          ValidatesNumericalityOf.new(:foo, option_name => compared_value)
        end

        Array(comparisons[:ok]).each do |ok_value|
          it "accepts the value '#{ok_value}'" do
            object.foo = ok_value
            violations = validator.violations_of(object).on_attribute(:foo)
            expect(violations.of_type(option_name)).to be_empty
          end
        end

        Array(comparisons[:not_ok]).each do |not_ok_value|
          it "rejects the value '#{not_ok_value}'" do
            object.foo = not_ok_value
            violations = validator.violations_of(object).on_attribute(:foo)
            expect(violations.of_type(option_name)).to_not be_empty
          end
        end
      end
    end

    it "accepts an :if condition that can block the validation" do
      validator = ValidatesNumericalityOf.new :foo, :if => :bar

      triggers       = double(:foo => "not a number", :bar => true)
      doesnt_trigger = double(:foo => "not a number", :bar => false)

      result = validator.violations_of(triggers)
      expect(result).to_not be_ok

      result = validator.violations_of(doesnt_trigger)
      expect(result).to be_ok
    end

    it "accepts an :unless condition that can block the validation" do
      validator = ValidatesNumericalityOf.new :foo, :unless => :bar

      triggers       = double(:foo => "not a number", :bar => false)
      doesnt_trigger = double(:foo => "not a number", :bar => true)

      result = validator.violations_of(triggers)
      expect(result).to_not be_ok

      result = validator.violations_of(doesnt_trigger)
      expect(result).to be_ok
    end
  end
end
