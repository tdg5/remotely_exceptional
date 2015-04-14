# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "remotely_exceptional/version"

Gem::Specification.new do |spec|
  spec.name          = "remotely_exceptional"
  spec.version       = RemotelyExceptional::VERSION
  spec.authors       = ["Danny Guinther"]
  spec.email         = ["dannyguinther@gmail.com"]
  spec.summary       = %q{Remote control of exceptions raised in distant contexts.}
  spec.description   = %q{Remote control of exceptions raised in distant contexts.}
  spec.homepage      = "https://github.com/tdg5/remotely_exceptional"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 0"
end
