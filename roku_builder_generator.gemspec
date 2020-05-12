# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "roku_builder_generator/version"

Gem::Specification.new do |spec|
  spec.name          = "roku_builder_generator"
  spec.version       = RokuBuilderGenerator::VERSION
  spec.authors       = ["Mark Pearce"]
  spec.email         = ["mark.pearce@redspace.com"]

  spec.summary       = %q{RokuBuilder Generator Plugin}
  spec.description   = %q{Plugin for RokuBuilder to do code generation for Brightscript}
  spec.homepage      = ""

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "roku_builder", "~> 4.4"

  spec.add_development_dependency "bundler", "~> 2.1"
end