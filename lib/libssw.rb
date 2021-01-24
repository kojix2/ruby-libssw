# frozen_string_literal: true

require_relative 'ssw/version'
require_relative 'ssw/BLOSUM50'
require_relative 'ssw/BLOSUM62'
require_relative 'ssw/dna'
require_relative 'ssw/aaseq'

module SSW
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end

  lib_name = case RbConfig::CONFIG['host_os']
             when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
               'libssw.dll'   # unconfirmed
             when /darwin|mac os/
               'libssw.dylib' # unconfirmed
             else
               'libssw.so'
             end

  self.ffi_lib = if ENV['LIBSSWDIR'] && !ENV['LIBSSWDIR'].empty?
                   File.expand_path(lib_name, ENV['LIBSSWDIR'])
                 else
                   File.expand_path("../vendor/#{lib_name}", __dir__)
                 end

  require_relative 'ssw/ffi'
  require_relative 'ssw/profile'
  require_relative 'ssw/align'

  class << self
    # Create the query profile using the query sequence.
    # @param read [Array] query sequence; the query sequence needs to be numbers
    # @param mat [Array] substitution matrix; mat needs to be corresponding to the read sequence
    # @param n [Integer] the square root of the number of elements in mat (mat has n*n elements)
    #                    If you omit this argument, the square root of the size of mat will be set.
    # @param score_size [Integer]
    #   estimated Smith-Waterman score;
    #   * if your estimated best alignment score is surely < 255 please set 0;
    #   * if your estimated best alignment score >= 255, please set 1;
    #   * if you don't know, please set 2
    def init(read, mat, n = nil, score_size: 2)
      read = read.to_a
      mat = mat.to_a.flatten
      raise ArgumentError, 'Expect class of read to be Array' unless read.is_a?(Array)
      raise ArgumentError, 'Expect class of mat to be Array' unless mat.is_a?(Array)

      read_str = read.pack('c*')
      read_len = read.size
      n = Math.sqrt(mat.size) if n.nil?
      raise "Not a square matrix. size: #{mat.size}, n: #{n}" if mat.size != n * n

      mat_str = mat.flatten.pack('c*')
      ptr = FFI.ssw_init(
        read_str,
        read_len,
        mat_str,
        n,
        score_size
      )
      # Garbage collection workaround
      #
      # * The following code will cause a segmentation violation when manually
      #   releasing memory. The reason is unknown.
      # * func_map is only available in newer versions of fiddle.
      # ptr.free = FFI.instance_variable_get(:@func_map)['init_destroy']
      ptr.instance_variable_set(:@read_str,   read_str)
      ptr.instance_variable_set(:@read_len,   read_len)
      ptr.instance_variable_set(:@mat_str,    mat_str)
      ptr.instance_variable_set(:@n,          n)
      ptr.instance_variable_set(:@score_size, score_size)

      SSW::Profile.new(ptr)
    end

    # Release the memory allocated by function ssw_init.
    # @param p [Fiddle::Pointer, SSW::Profile, SSW::FFI::Profile]
    #   pointer to the query profile structure
    # @note Ruby has garbage collection, so there is not much reason to call
    #   this method.
    def init_destroy(profile)
      unless profile.is_a?(Fiddle::Pointer) || prof.is_a?(Profile) || prof.respond_to?(:to_ptr)
        raise ArgumentError, 'Expect class of filename to be Profile or Pointer'
      end

      FFI.init_destroy(profile)
    end

    # Do Striped Smith-Waterman alignment.
    # @param prof [Fiddle::Pointer, SSW::Profile, SSW::FFI::Profile]
    #   pointer to the query profile structure
    # @param ref [Array]
    #   target sequence;
    #   the target sequence needs to be numbers and corresponding to the mat
    #   parameter of function ssw_init
    # @param weight_gap0 [Integer] the absolute value of gap open penalty
    # @param weight_gapE [Integer] the absolute value of gap extension penalty
    # @param flag [Integer]
    #   * bit 5: when setted as 1, function ssw_align will return the best
    #     alignment beginning position;
    #   * bit 6: when setted as 1, if (ref_end1 - ref_begin1 < filterd &&
    #     read_end1 - read_begin1 < filterd), (whatever bit 5 is setted) the
    #     function will return the best alignment beginning position and cigar;
    #   * bit 7: when setted as 1, if the best alignment score >= filters,
    #     (whatever bit 5 is setted) the function   will return the best
    #     alignment beginning position and cigar;
    #   * bit 8: when setted as 1, (whatever bit 5, 6 or 7 is  setted) the
    #     function will always return the best alignment beginning position and
    #     cigar. When flag == 0, only the optimal and sub-optimal scores and the
    #     optimal alignment ending position will be returned.
    # @param filters [Integer]
    #   scorefilter: when bit 7 of flag is setted as 1 and bit 8 is setted as 0,
    #   filters will be used (Please check the decription of the flag parameter
    #   for detailed usage.)
    # @param filterd [Integer]
    #   distance filter: when bit 6 of flag is setted as 1 and bit 8 is setted
    #   as 0, filterd will be used (Please check the decription of the flag
    #   parameter for detailed usage.)
    # @param mask_len [Integer]
    #   The distance between the optimal and suboptimal alignment ending
    #   position >= maskLen. We suggest to use readLen/2, if you don't have
    #   special concerns. Note: maskLen has to be >= 15, otherwise this function
    #   will NOT return the suboptimal alignment information. Detailed
    #   description of maskLen: After locating the optimal alignment ending
    #   position, the suboptimal alignment score can be heuristically found by
    #   checking the second largest score in the array that contains the maximal
    #   score of each column of the SW matrix. In order to avoid picking the
    #   scores that belong to the alignments sharing the partial best alignment,
    #   SSW C library masks the reference loci nearby (mask length = maskLen)
    #   the best alignment ending position and locates the second largest score
    #   from the unmasked elements.
    def align(prof, ref, weight_gap0, weight_gapE, flag, filters, filterd, mask_len = nil)
      unless prof.is_a?(Fiddle::Pointer) || prof.is_a?(Profile) || prof.respond_to?(:to_ptr)
        raise ArgumentError, 'Expect class of filename to be Profile or Pointer'
      end
      raise ArgumentError, 'Expect class of ref to be Array' unless ref.is_a?(Array)

      ref_str = ref.pack('c*')
      ref_len = ref.size
      mask_len ||= [ref_len / 2, 15].max
      ptr = FFI.ssw_align(
        prof, ref_str, ref_len, weight_gap0, weight_gapE, flag, filters, filterd, mask_len
      )
      # Not sure yet if we should set the instance variable to the pointer as a
      # garbage collection workaround.
      # For example: instance_variable_set(:@ref_str, ref_str)
      #
      # ptr.free = FFI.instance_variable_get(:@func_map)['align_destroy']
      SSW::Align.new(ptr)
    end

    # Release the memory allocated by function ssw_align.
    # @param a [Fiddle::Pointer, SSW::Align, SSW::FFI::Align]
    #   pointer to the alignment result structure
    def align_destroy(align)
      if align.is_a?(Align)
        warn "You don't need to call this method for Ruby's Align class."
        nil
      elsif align.is_a?(Fiddle::Pointer) || align.respond_to?(:to_ptr)
        FFI.align_destroy(align)
      else
        raise ArgumentError, 'Expect class of filename to be Pointer'
      end
    end

    # 1. Calculate the number of mismatches.
    # 2. Modify the cigar string:
    # differentiate matches (=), mismatches(X), and softclip(S).
    # @note This method takes a Fiddle::Pointer as an argument. Please read the
    #   source code and understand it well before using this method.
    #   (Needs to be improved)
    # @param ref_begin1 [Integer]
    #   0-based best alignment beginning position on the reference sequence
    # @param read_begin1 [Integer]
    #   0-based best alignment beginning position on the read sequence
    # @param read_end1 [Integer]
    #   0-based best alignment ending position on the read sequence
    # @param ref [Array]
    #   reference sequence
    # @param read [Array]
    #   read sequence
    # @param read_len [Integer] length of the read
    # @param cigar [Fiddle::Pointer]
    #   best alignment cigar; stored the same as that in BAM format,
    #   high 28 bits: length, low 4 bits: M/I/D (0/1/2)
    # @param cigar_len [Integer] length of the cigar string
    # @return [Integer] The number of mismatches. The cigar and cigarLen are modified.
    def mark_mismatch(ref_begin1, read_begin1, read_end1, ref, read, read_len, cigar, cigar_len)
      warn 'implementation: fiexme: **cigar' # FIXME
      FFI.mark_mismatch(
        ref_begin1, read_begin1, read_end1, ref.pack('c*'), read.pack('c*'), read_len, cigar, cigar_len.pack('l*')
      )
    end

    # Create scoring matrix of Smith-Waterman algrithum.
    # @param [Array] elements
    # @param [Integer] match_score
    # @param [Integer] mismatch_score
    def create_scoring_matrix(elements, match_score, mismatch_score)
      size = elements.size
      score = Array.new(size * size, 0)
      (size - 1).times do |i|
        (size - 1).times do |j|
          score[i * size + j] = \
            (elements[i] == elements[j] ? match_score : mismatch_score)
        end
      end
      score
    end
  end
end
