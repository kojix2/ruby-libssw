# frozen_string_literal: true

require_relative 'libssw/version'

module LibSSW
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end
end
