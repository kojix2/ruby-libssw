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
      # The pointer already contains the correct C structure.
      # The instance variables on @ptr (@read_str, @mat_str, etc.) are kept
      # alive to prevent garbage collection of the memory that C is referencing.
      # We don't need to modify the C structure here.
      @ptr
    end

    def to_h
      self.class.keys.map { |k| [k, __send__(k)] }.to_h
    end
  end
end
