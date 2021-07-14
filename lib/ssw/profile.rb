# frozen_string_literal: true

module SSW
  # structure of the query profile/usr/lib/x86_64-linux-gnu/
  # @!attribute read
  # @!attribute mat
  # @!attribute read_len
  # @!attribute n
  # @!attribute bias
  class Profile
    def self.keys
      %i[read mat read_len n bias]
    end

    # This class is read_only
    attr_reader(*keys, :ptr, :cstruct)

    def initialize(ptr)
      @ptr      = ptr
      @cstruct  = profile = SSW::LibSSW::Profile.new(ptr)
      @read_len = profile.readLen
      @read     = read_len.positive? ? profile.read[0, read_len].unpack('c*') : []
      @n        = profile.n
      @mat      = n.positive? ? profile.mat[0, n * n].unpack('c*') : []
      @bias     = profile.bias
    end

    def to_ptr
      # Garbage collection warkaround
      # Preventing Garbage Collection --force
      cstruct.read    = ptr.instance_variable_get(:@read_str)
      cstruct.mat     = ptr.instance_variable_get(:@mat_str)
      cstruct.readLen = ptr.instance_variable_get(:@read_len)
      cstruct.n       = ptr.instance_variable_get(:@n)
      ptr
    end

    def to_h
      self.class.keys.map { |k| [k, __send__(k)] }.to_h
    end
  end
end
