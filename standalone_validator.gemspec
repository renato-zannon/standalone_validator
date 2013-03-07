# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'standalone_validator/version'

Gem::Specification.new do |spec|
  spec.name          = "standalone_validator"
  spec.version       = StandaloneValidator::VERSION
  spec.authors       = ["Renato Zannon"]
  spec.email         = ["renato.riccieri@gmail.com"]
  spec.description   = <<-DESCRIPTION
    A library for creating PORO validators that are composable and can be used
    with ActiveRecord or standalone.
  DESCRIPTION

  spec.summary       = %q{PORO standalone validators compatible with ActiveRecord}
  spec.homepage      = "http://github.com/riccieri/standalone_validator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "hamster", "~> 0.4"
  spec.add_dependency "virtus",  "~> 0.4"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec",   "~> 2.13"
  spec.add_development_dependency "rake"
end
