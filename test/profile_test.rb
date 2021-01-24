# frozen_string_literal: true

require_relative 'test_helper'

class ProfileTest < Minitest::Test
  def setup
    ptr = SSW::FFI::Profile.malloc
    @profile = SSW::Profile.new(ptr)
  end

  def test_keys
    assert_equal \
      %i[read
         mat
         read_len
         n
         bias],
      SSW::Profile.keys
  end

  def test_read
    assert_equal [], @profile.read
  end

  def test_mat
    assert_equal [], @profile.mat
  end

  def test_read_len
    assert_equal 0, @profile.read_len
  end

  def test_n
    assert_equal 0, @profile.n
  end

  def test_bias
    assert_equal 0, @profile.bias
  end

  def test_to_h
    assert_equal SSW::Profile.keys, @profile.to_h.keys
    assert_equal [[], [], 0, 0, 0], @profile.to_h.values
  end
end
