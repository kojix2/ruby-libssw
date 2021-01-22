# frozen_string_literal: true

require_relative 'test_helper'

class LibsswTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil LibSSW::VERSION
  end

  def test_align_struct_malloc
    assert_instance_of LibSSW::FFI::Align, (ptr = LibSSW::FFI::Align.malloc)
    assert_instance_of LibSSW::Align, LibSSW::Align.new(ptr)
  end

  def test_profile_struct_malloc
    assert_instance_of LibSSW::FFI::Profile, (ptr = LibSSW::FFI::Profile.malloc)
    assert_instance_of LibSSW::Profile, LibSSW::Profile.new(ptr)
  end

  def test_ssw_init1
    read = Array.new(100) { [0, 1, 2, 3, 4].sample }
    read_len = read.size
    n = 5
    mat = Array.new(n * n) { [-2, -1, 0, 1, 2].sample }
    profile = LibSSW.ssw_init(read, mat, n)
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
    profile = LibSSW.ssw_init(read, mat, n, score_size: 2)
    assert_instance_of LibSSW::Profile, profile
    assert_equal read, profile.read
    assert_equal mat, profile.mat
    assert_equal read_len, profile.read_len
    assert_equal n, profile.n
    assert_instance_of Integer, profile.bias
  end

  def test_init_destroy1
    read = Array.new(100) { [0, 1, 2, 3, 4].sample }
    n = 5
    mat = Array.new(n * n) { [-2, -1, 0, 1, 2].sample }
    profile = LibSSW.ssw_init(read, mat, n)
    assert_nil LibSSW.init_destroy(profile)
  end

  def test_ssw_align
    ref = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    read = [0, 1, 2, 3, 3]
    n = 5
    mat = [2, -2, -2, -2, 0,
           -2,  2, -2, -2,  0,
           -2, -2,  2, -2,  0,
           -2, -2, -2,  2,  0,
           0, 0, 0, 0, 0]
    profile = LibSSW.ssw_init(read, mat, n, score_size: 2)
    align = LibSSW.ssw_align(profile, ref, 3, 1, 1, 0, 0, 15)
    assert_equal 10, align.score1
    assert_equal 3, align.score2
    assert_equal 9, align.ref_begin1
    assert_equal 13, align.ref_end1
    assert_equal 0, align.read_begin1
    assert_equal 4, align.read_end1
    assert_equal 29, align.ref_end2
    assert_equal [80], align.cigar
    assert_equal 1, align.cigar_len
    assert_equal '5M', align.cigar_string
  end

  def test_create_scoring_matrix
    mat1 = [2, -2, -2, -2, 0,
            -2,  2, -2, -2, 0,
            -2, -2,  2, -2, 0,
            -2, -2, -2,  2, 0,
            0, 0, 0, 0, 0]
    assert_equal mat1, LibSSW.create_scoring_matrix(LibSSW::DNAElements, 2, -2)
    mat2 = [5, -3, -3, -3, 0,
            -3, 5, -3, -3, 0,
            -3, -3, 5, -3, 0,
            -3, -3, -3, 5, 0,
            0, 0, 0, 0, 0]
    assert_equal mat2, LibSSW.create_scoring_matrix(LibSSW::DNAElements, 5, -3)
  end
end
