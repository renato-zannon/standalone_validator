# StandaloneValidator
[![Build Status](https://secure.travis-ci.org/riccieri/standalone_validator.png)](http://travis-ci.org/riccieri/standalone_validator)

A library for creating PORO validators that are composable and can be used with ActiveRecord or standalone.

## Installation

Add this line to your application's Gemfile:

    gem 'standalone_validator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install standalone_validator

## Usage

```ruby
require 'standalone_validator'

NameLengthValidator = StandaloneValidator.create do
  def initialize(min_length, attribute_name = :name)
    @min_length = min_length
    @attribute_name = attribute_name
  end

  include_validation do |object, result|
    if object.send(attribute_name).length < @min_length
      result.add_violation(attribute_name, 'should be bigger')
    end
  end

private

  attr_reader :attribute_name
end

AllNamesValidator = StandaloneValidator.create do
  include_validation NameLengthValidator, 5
  include_validation NameLengthValidator, 4, :last_name
end


Person = Struct.new(:name, :last_name)
validator = AllNamesValidator.new

person = Person.new("Renato", "Zannon")
puts validator.violations_of(person).any? # false

other_person = Person.new("Renato", "Foo")
puts validator.violations_of(other_person).any? # true

validator.violations_of(other_person).each do |violation|
  puts violation.attribute.inspect # :last_name
  puts violation.message.inspect   # "should be bigger"
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
