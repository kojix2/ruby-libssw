# frozen_string_literal: true

require_relative 'struct_helper'

module LibSSW
  # structure of the query profile/usr/lib/x86_64-linux-gnu/
  # @!attribute read
  # @!attribute mat
  # @!attribute read_len
  # @!attribute n
  # @!attribute bias
  class Profile < FFI::Profile
    include StructHelper

    def self.keys
      %i[read mat read_len n bias]
    end

    # This class is read_only
    attr_reader(*keys, :ptr, :cstruct)

    def initialize(ptr)
      @ptr      = ptr
      @cstruct  = profile = LibSSW::FFI::Profile.new(ptr)
      @read_len = profile.readLen
      @read     = read_len.positive? ? profile.read[0, read_len].unpack('c*') : []
      @n        = profile.n
      @mat      = n.positive? ? profile.mat[0, n * n].unpack('c*') : []
      @bias     = profile.bias
    end

    def to_ptr
      # Garbage collection warkaround
      # cstruct.read    = p @ptr.instance_variable_get(:@read_str)
      # cstruct.mat     = p @ptr.instance_variable_get(:@mat_str)
      # cstruct.readLen = p @ptr.instance_variable_get(:@read_len)
      # cstruct.n       = p @ptr.instance_variable_get(:@n)
      @ptr
    end
  end
end
