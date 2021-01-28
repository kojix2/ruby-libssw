# frozen_string_literal: true

require_relative 'test_helper'

class LibsswTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil SSW::VERSION
  end

  # def test_instance_variable_func_map_available
  #   refute_nil SSW::FFI.instance_variable_get(:@func_map)
  # end

  def test_align_struct_malloc
    assert_instance_of SSW::FFI::Align, (ptr = SSW::FFI::Align.malloc)
    assert_instance_of SSW::Align, SSW::Align.new(ptr)
  end

  def test_profile_struct_malloc
    assert_instance_of SSW::FFI::Profile, (ptr = SSW::FFI::Profile.malloc)
    assert_instance_of SSW::Profile, SSW::Profile.new(ptr)
  end

  def test_ssw_init1
    read = Array.new(100) { [0, 1, 2, 3, 4].sample }
    read_len = read.size
    n = 5
    mat = Array.new(n * n) { [-2, -1, 0, 1, 2].sample }
    profile = SSW.init(read, mat, n)
    assert_instance_of SSW::Profile, profile
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
    profile = SSW.init(read, mat, n, score_size: 2)
    assert_instance_of SSW::Profile, profile
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
    profile = SSW.init(read, mat, n)
    assert_nil SSW.init_destroy(profile.to_ptr)
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
    profile = SSW.init(read, mat, n, score_size: 2)
    align = SSW.align(profile, ref, 3, 1, 1, 0, 0, 15)
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

  def test_ssw_align2
    ref = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    read = [0, 1, 2, 3, 3]
    mat = [2, -2, -2, -2, 0,
           -2,  2, -2, -2,  0,
           -2, -2,  2, -2,  0,
           -2, -2, -2,  2,  0,
           0, 0, 0, 0, 0]
    profile = SSW.init(read, mat, score_size: 2)
    align = SSW.align(profile, ref, 3, 1, 0, 0, 0) # flag 0, omit mask len
    assert_equal 10, align.score1
    assert_equal 3, align.score2
    assert_equal(-1, align.ref_begin1)
    assert_equal 13, align.ref_end1
    assert_equal(-1, align.read_begin1)
    assert_equal 4, align.read_end1
    assert_equal 29, align.ref_end2
    assert_equal [], align.cigar
    assert_equal 0, align.cigar_len
    assert_equal '', align.cigar_string
  end

  def test_build_path
    ref_str  = 'AAAAAAAAACGTTAAAAAAAAAA'
    ref_int  = SSW::DNA.to_int_array(ref_str)
    read_str = 'ACGTT'
    read_int = SSW::DNA.to_int_array(read_str)
    mat = [2, -2, -2, -2, 0,
           -2,  2, -2, -2,  0,
           -2, -2,  2, -2,  0,
           -2, -2, -2,  2,  0,
           0, 0, 0, 0, 0]
    profile = SSW.init(read_int, mat)
    align = SSW.align(profile, ref_int, 3, 1, 1, 0, 0)
    assert_equal ['5M', 'ACGTT', '|||||', 'ACGTT'],
                 SSW.build_path(read_str, ref_str, align)
  end

  def test_build_path2
    ref_str  = 'GGTGGTATACAANTTNAGNNGTTGGTCNACCAATAGCAGTGGGCATGCTNNGAATAATACTTACCCTATNGCGATNTCCTTACACTGGTAAAGAATGTCTT'
    ref_int  = SSW::DNA.to_int_array(ref_str)
    read_str = 'CTCTTAGGCCCGCAGTTTCC'
    read_int = SSW::DNA.to_int_array(read_str)
    mat = [2, -2, -2, -2, 0,
           -2,  2, -2, -2,  0,
           -2, -2,  2, -2,  0,
           -2, -2, -2,  2,  0,
           0, 0, 0, 0, 0]
    profile = SSW.init(read_int, mat)
    align = SSW.align(profile, ref_int, 3, 1, 1, 0, 0)
    assert_equal ['4M2I3M4D9M', 'CTTAGGCCC    GCAGTTTCC', '||||  |||    ||**|*|||', 'CTTA  CCCTATNGCGATNTCC'],
                 SSW.build_path(read_str, ref_str, align)
  end

  def test_create_scoring_matrix
    mat1 = [2, -2, -2, -2, 0,
            -2,  2, -2, -2, 0,
            -2, -2,  2, -2, 0,
            -2, -2, -2,  2, 0,
            0, 0, 0, 0, 0]
    assert_equal mat1, SSW.create_scoring_matrix(SSW::DNA::Elements, 2, -2)
    mat2 = [5, -3, -3, -3, 0,
            -3, 5, -3, -3, 0,
            -3, -3, 5, -3, 0,
            -3, -3, -3, 5, 0,
            0, 0, 0, 0, 0]
    assert_equal mat2, SSW.create_scoring_matrix(SSW::DNA::Elements, 5, -3)
  end

  def test_dna_to_int_array
    seq = 'TCGATCGATCGANNNNM'
    int = [3, 1, 2, 0, 3, 1, 2, 0, 3, 1, 2, 0, 4, 4, 4, 4, 4]
    assert_equal int, SSW::DNA.to_int_array(seq)
    assert_equal int.reverse, SSW::DNA.to_int_array(seq.reverse)
  end

  def test_int_array_to_dna
    int = [3, 1, 2, 0, 3, 1, 2, 0, 3, 1, 2, 0, 4, 4, 4, 4, 5]
    seq = 'TCGATCGATCGANNNNN'
    assert_equal seq, SSW::DNA.from_int_array(int)
    assert_equal seq.reverse, SSW::DNA.from_int_array(int.reverse)
  end

  def test_dna_revcomp
    s = 'TCGAtcgaN'
    r = 'NTCGATCGA'
    assert_equal r, SSW::DNA.revcomp(s)
  end

  def test_aaseq_to_int_array
    aa_seq = 'ACDEFGHIKLMNPQRSTVWYU*'
    arr = [0, 4, 3, 6, 13, 7, 8, 9, 11, 10, 12, 2, 14, 5, 1, 15, 16, 19, 17, 18, 23, 23]
    assert_equal arr, SSW::AASeq.to_int_array(aa_seq)
  end

  def test_int_array_to_aaseq
    arr = [0, 4, 3, 6, 13, 7, 8, 9, 11, 10, 12, 2, 14, 5, 1, 15, 16, 19, 17, 18, 23, 28]
    aa_seq = 'ACDEFGHIKLMNPQRSTVWY**'
    assert_equal aa_seq, SSW::AASeq.from_int_array(arr)
  end
end
