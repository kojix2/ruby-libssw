# frozen_string_literal: true

module SSW
  # structure of the alignment result
  # @!attribute score1
  #   @return [Integer] the best alignment score
  # @!attribute score2
  #   @return [Integer] sub-optimal alignment score
  # @!attribute ref_begin1
  #   @return [Integer]
  #     0-based best alignment beginning position on reference;
  #     ref_begin1 = -1 when the best alignment beginning position is not available
  # @!attribute ref_end1
  #   @return [Integer] 0-based best alignment ending position on reference
  # @!attribute read_begin1
  #   @return [Integer]
  #     0-based best alignment beginning position on read;
  #     read_begin1 = -1 when the best alignment beginning position is not available
  # @!attribute read_end1
  #   @return [Integer] 0-based best alignment ending position on read
  # @!attribute read_end2
  #   @return [Integer] 0-based sub-optimal alignment ending position on read
  # @!attribute cigar [r]
  #   @return [Array]
  #     best alignment cigar; stored the same as that in BAM format,
  #     high 28 bits: length, low 4 bits: M/I/D (0/1/2);
  #     cigar = 0 when the best alignment path is not available
  # @!attribute cigar_len
  #   @return [Integer]
  #     length of the cigar string; cigarLen = 0 when the best alignment path is not available
  # @!attribute cigar_string
  #   @return [String] cigar string
  class Align
    def self.keys
      %i[score1 score2 ref_begin1 ref_end1
         read_begin1 read_end1 ref_end2 cigar cigar_len cigar_string]
    end

    # This class is read_only
    attr_reader(*keys)

    def initialize(ptr)
      @ptr          = ptr
      @cstruct      = align = LibSSW::Align.new(ptr)
      @score1       = align.score1
      @score2       = align.score2
      @ref_begin1   = align.ref_begin1
      @ref_end1     = align.ref_end1
      @read_begin1  = align.read_begin1
      @read_end1    = align.read_end1
      @ref_end2     = align.ref_end2
      @cigar_len    = align.cigarLen
      @cigar        = cigar_len.positive? ? align.cigar[0, 4 * cigar_len].unpack('L*') : []
      # Attributes for ruby binding only
      @cigar_string = array_to_cigar_string(@cigar)
      SSW.align_destroy(ptr)
    end

    def to_h
      self.class.keys.map { |k| [k, __send__(k)] }.to_h
    end

    private

    def array_to_cigar_string(arr)
      cigar_string = String.new
      arr.each do |x|
        n = x >> 4
        m = x & 15
        c = m > 8 ? 'M' : 'MIDNSHP=X'[m]
        cigar_string << n.to_s << c
      end
      cigar_string
    end
  end
end
