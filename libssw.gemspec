# frozen_string_literal: true

require_relative 'lib/ssw/version'

Gem::Specification.new do |spec|
  spec.name          = 'libssw'
  spec.version       = SSW::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'Ruby bindings for libssw'
  spec.description   = 'Ruby bindings for libssw'
  spec.homepage      = 'https://github.com/kojix2/ruby-libssw'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.5'

  spec.files         = Dir['*.{md,txt}', '{lib,exe}/**/*', 'vendor/libssw.so', 'vendor/libssw.dylib']
  spec.bindir        = 'exe'
  spec.executables   = 'rbssw'
  spec.require_paths = ['lib']

  spec.add_dependency 'fiddle', '>=1.0.7'

  spec.add_development_dependency 'bio'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
