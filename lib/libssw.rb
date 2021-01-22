# frozen_string_literal: true

require_relative 'libssw/version'
require_relative 'libssw/BLOSUM50'
require_relative 'libssw/BLOSUM62'

module LibSSW
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

  require_relative 'libssw/ffi'
  require_relative 'libssw/profile'
  require_relative 'libssw/align'

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
    def ssw_init(read, mat, n = nil, score_size: 2)
      read_str = read.pack('c*')
      read_len = read.size
      mat = mat.to_a.flatten
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
      profile = LibSSW::Profile.new(ptr)
      # Check Garbage Collection
      %i[read read_len mat n].zip([read, read_len, mat, n]).each do |name, obj|
        next unless profile.public_send(name) != obj

        warn "[Error] Struct member: '#{name}'"
        warn "        * expected value: #{obj}"
        warn "        *   actual value: #{profile.public_send(name)}"
        warn "        This may have been caused by Ruby'S GC."
      end
      # Preventing Garbage Collection --force
      cstruct         = profile.cstruct
      cstruct.read    = read_str
      cstruct.mat     = mat_str
      cstruct.readLen = read_len
      cstruct.n       = n
      ptr.instance_variable_set(:@read_str, read_str)
      ptr.instance_variable_set(:@read_len, read_len)
      ptr.instance_variable_set(:@mat_str,  mat_str)
      ptr.instance_variable_set(:@n,        n)
      profile
    end

    # Release the memory allocated by function ssw_init.
    # @param p [Fiddle::Pointer, LibSSW::Profile, LibSSW::FFI::Profile]
    #   pointer to the query profile structure
    # @note Ruby has garbage collection, so there is not much reason to call
    #   this method.
    def init_destroy(profile)
      FFI.init_destroy(profile)
    end

    # Do Striped Smith-Waterman alignment.
    # @param prof [Fiddle::Pointer, LibSSW::Profile, LibSSW::FFI::Profile]
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
    def ssw_align(prof, ref, weight_gap0, weight_gapE, flag, filters, filterd, mask_len)
      ref_str = ref.pack('c*')
      ref_len = ref.size
      ptr = FFI.ssw_align(
        prof, ref_str, ref_len, weight_gap0, weight_gapE, flag, filters, filterd, mask_len
      )
      # Not sure yet if we should set the instance variable to the pointer as a
      # garbage collection workaround.
      # For example: instance_variable_set(:@ref_str, ref_str)
      LibSSW::Align.new(ptr)
    end

    # Release the memory allocated by function ssw_align.
    # @param a [Fiddle::Pointer, LibSSW::Align, LibSSW::FFI::Align]
    #   pointer to the alignment result structure
    def align_destroy(align)
      FFI.align_destroy(align)
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

    AAELEMENTS = ['A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G',
                  'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S',
                  'T', 'W', 'Y', 'V', 'B', 'Z', 'X', '*']

    AA2INT = { 'A' => 0,  'a' => 0,
               'R' => 1,  'r' => 1,
               'N' => 2,  'n' => 2,
               'D' => 3,  'd' => 3,
               'C' => 4,  'c' => 4,
               'Q' => 5,  'q' => 5,
               'E' => 6,  'e' => 6,
               'G' => 7,  'g' => 7,
               'H' => 8,  'h' => 8,
               'I' => 9,  'i' => 9,
               'L' => 10, 'l' => 10,
               'K' => 11, 'k' => 11,
               'M' => 12, 'm' => 12,
               'F' => 13, 'f' => 13,
               'P' => 14, 'p' => 14,
               'S' => 15, 's' => 15,
               'T' => 16, 't' => 16,
               'W' => 17, 'w' => 17,
               'Y' => 18, 'y' => 18,
               'V' => 19, 'v' => 19,
               'B' => 20, 'b' => 20,
               'Z' => 21, 'z' => 21,
               'X' => 22, 'x' => 22,
               '*' => 23 }

    INT2AA = { 0 => 'A', 1 => 'R', 2 => 'N', 3 => 'D',
               4 => 'C', 5 => 'Q', 6 => 'E', 7 => 'G',
               8 => 'H', 9 => 'I', 10 => 'L', 11 => 'K',
               12 => 'M', 13 => 'F', 14 => 'P', 15 => 'S',
               16 => 'T', 17 => 'W', 18 => 'Y', 19 => 'V',
               20 => 'B', 21 => 'Z', 22 => 'X', 23 => '*' }

    DNAElements = %w[A C G T N]

    DNA2INT = { 'A' => 0, 'a' => 0,
                'C' => 1, 'c' => 1,
                'G' => 2, 'g' => 2,
                'T' => 3, 't' => 3,
                'N' => 4, 'n' => 4 }

    INT2DNA = { 0 => 'A', 1 => 'C', 2 => 'G', 3 => 'T', 4 => 'N' }

    # reverse complement
    DNARC = { 'A': 'C',
              'C': 'G',
              'G': 'C',
              'T': 'A',
              'a': 'C',
              'c': 'G',
              'g': 'C',
              't': 'A' }
  end
end
