# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
require 'bundler/setup'
Bundler.require(:default)
require 'libssw'

require 'minitest/autorun'
require 'minitest/pride'
