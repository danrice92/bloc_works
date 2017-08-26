# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bloc_works/version'

Gem::Specification.new do |spec|
  spec.name          = "bloc_works"
  spec.version       = BlocWorks::VERSION
  spec.authors       = ["Dan Rice"]
  spec.email         = ["dan.rice.92@outlook.com"]

  spec.summary       = %q{Learning Web Framework.}
  spec.description   = %q{Rails-inspired learning Web Framework.}
  spec.homepage      = "https://github.com/danrice92/bloc_works"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack", "~> 1.6"
  spec.add_development_dependency "test-unit", "1.2.3"
  spec.add_development_dependency "rack-test"
  spec.add_runtime_dependency "erubis", "~>2.7"
  spec.add_runtime_dependency "bloc_record"
end
