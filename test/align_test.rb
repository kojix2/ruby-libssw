# frozen_string_literal: true

require_relative 'test_helper'

class AlignTest < Minitest::Test
  def setup
    ptr = LibSSW::FFI::Align.malloc
    @align = LibSSW::Align.new(ptr)
  end

  def test_keys
    assert_equal \
      %i[score1
         score2
         ref_begin1
         ref_end1
         read_begin1
         read_end1
         ref_end2
         cigar
         cigar_len
         cigar_string],
      LibSSW::Align.keys
  end

  def test_score1
    assert_equal 0, @align.score1
  end

  def test_score2
    assert_equal 0, @align.score2
  end

  def test_ref_begin1
    assert_equal 0, @align.ref_begin1
  end

  def test_read_begin1
    assert_equal 0, @align.read_begin1
  end

  def test_read_end1
    assert_equal 0, @align.read_end1
  end

  def test_ref_end2
    assert_equal 0, @align.ref_end2
  end

  def test_cigar
    assert_equal [], @align.cigar
  end

  def test_cigar_len
    assert_equal 0, @align.cigar_len
  end

  def test_cigar_string
    assert_equal '', @align.cigar_string
  end

  def test_to_h
    assert_equal LibSSW::Align.keys, @align.to_h.keys
    assert_equal [0, 0, 0, 0, 0, 0, 0, [], 0, ''], @align.to_h.values
  end
end
