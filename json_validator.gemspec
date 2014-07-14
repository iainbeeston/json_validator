# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "json_validator_meta"

Gem::Specification.new do |spec|
  spec.name          = "json_validator"
  spec.version       = JsonValidatorMeta::VERSION
  spec.authors       = ["Iain Beeston"]
  spec.email         = ["iain.beeston@gmail.com"]
  spec.summary       = %q{ActiveModel that validates hash fields using JSON schema}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.2"
  spec.add_dependency "activemodel", ">= 3.2"
  spec.add_dependency "json-schema"
  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
end
