# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'directree/version'

Gem::Specification.new do |spec|
  spec.name          = "directree"
  spec.version       = Directree::VERSION
  spec.authors       = ["Kunal Dabir"]
  spec.email         = ["kunal.dabir@gmail.com"]
  spec.summary       = %q{create directory trees and files with contents}
  spec.description   = %q{directree is convenient DSL for creating directory tree and text files with content}
  spec.homepage      = "http://github.com/kdabir/directree.rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
end
