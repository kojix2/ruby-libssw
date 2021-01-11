# frozen_string_literal: true

require_relative 'test_helper'

class ProfileTest < Minitest::Test
  def setup
    @align = LibSSW::Profile.malloc
  end

  def test_initialization
    assert_instance_of Fiddle::Pointer, @align.byte
    assert_instance_of Fiddle::Pointer, @align.word
    assert_equal [], @align.read
    assert_equal [], @align.mat
    assert_equal 0, @align.read_len
    assert_equal 0, @align.n
    assert_equal 0, @align.bias
  end
end
