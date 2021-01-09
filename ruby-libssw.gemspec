# frozen_string_literal: true

require_relative "lib/ruby/libssw/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby-libssw"
  spec.version       = SSW::VERSION
  spec.authors       = ["kojix2"]
  spec.email         = ["2xijok@gmail.com"]

  spec.summary       = "Ruby bindings for libssw"
  spec.description   = "Ruby bindings for libssw"
  spec.homepage      = "https://github.com/kojix2/ruby-libssw"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.5"

  spec.files         = Dir["*.{md,txt}", "{lib,exe}/**/*"]
  spec.bindir        = "exe"
  spec.executables   = 'rbssw'
  spec.require_paths = ["lib"]
end
