# frozen_string_literal: true

require_relative 'test_helper'

class LibsswTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil LibSSW::VERSION
  end

  def test_align_struct_malloc
    assert_instance_of LibSSW::FFI::Align, LibSSW::FFI::Align.malloc
    assert_instance_of LibSSW::Align, LibSSW::Align.malloc
  end

  def test_profile_struct_malloc
    assert_instance_of LibSSW::FFI::Profile, LibSSW::FFI::Profile.malloc
    assert_instance_of LibSSW::Profile, LibSSW::Profile.malloc
  end

  def test_ssw_init1
    read = Array.new(100) { [0, 1, 2, 3, 4].sample }
    read_len = read.size
    n = 5
    mat = Array.new(n * n) { [-2, -1, 0, 1, 2].sample }
    score_size = 2
    profile = LibSSW.ssw_init(read, read_len, mat, n, score_size)
    assert_instance_of LibSSW::Profile, profile
    assert_equal read, profile.read
    assert_equal mat, profile.mat
    assert_equal read_len, profile.read_len
    assert_equal n, profile.n
    assert_instance_of Integer, profile.bias
  end

  def test_ssw_init2
    read = Array.new(1000) { [0, 1, 2, 3, 4, 5, 6].sample }
    read_len = read.size
    n = 7
    mat = Array.new(n * n) { [-3, -2, -1, 0, 1, 2, 3].sample }
    score_size = 2
    profile = LibSSW.ssw_init(read, read_len, mat, n, score_size)
    assert_instance_of LibSSW::Profile, profile
    assert_equal read, profile.read
    assert_equal mat, profile.mat
    assert_equal read_len, profile.read_len
    assert_equal n, profile.n
    assert_instance_of Integer, profile.bias
  end
end
