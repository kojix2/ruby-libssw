# frozen_string_literal: true

require_relative 'test_helper'

class AlignTest < Minitest::Test
  def setup
    @align = LibSSW::Align.malloc
  end

  def test_initialization
    assert_equal 0, @align.score1
    assert_equal 0, @align.score2
    assert_equal 0, @align.ref_begin1
    assert_equal 0, @align.read_begin1
    assert_equal 0, @align.read_end1
    assert_equal 0, @align.ref_end2
    assert_equal [], @align.cigar
    assert_equal 0, @align.cigar_len
  end
end
