# frozen_string_literal: true

require_relative 'libssw/version'

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

  # structure of the alignment result
  # @!attribute score1
  #   @return [Integer] the best alignment score
  # @!attribute score2
  #   @return [Integer] sub-optimal alignment score
  # @!attribute ref_begin1
  #   @return [Integer] 
  #     0-based best alignment beginning position on reference;
  #	    ref_begin1 = -1 when the best alignment beginning position is not available
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
  class Align < FFI::Align
    def cigar
      pt = super
      return [] if cigar_len.zero?

      pt[0, 4 * cigar_len].unpack('L*')
    end

    def cigar_len
      cigarLen
    end

    def to_h
      h = {}
      %i[score1
         score2
         ref_begin1
         ref_end1
         read_begin1
         read_end1
         ref_end2
         cigar
         cigar_len].each do |k|
        h[k] = __send__(k)
      end
      h
    end
  end

  # structure of the query profile/usr/lib/x86_64-linux-gnu/
  # @!attribute read
  # @!attribute mat
  # @!attribute read_len
  # @!attribute n
  # @!attribute bias
  class Profile < FFI::Profile
    def read
      pt = super
      return [] if read_len.zero?

      pt[0, read_len].unpack('c*')
    end

    def mat
      pt = super
      return [] if n.zero?

      pt[0, n * n].unpack('c*')
    end

    def read_len
      readLen
    end

    def to_h
      h = {}
      %i[byte
         word
         read
         mat
         read_len
         n
         bias].each do |k|
        h[k] = __send__(k)
      end
      h
    end
  end

  class << self
    def ssw_init(read, read_len, mat, n, score_size)
      ptr = FFI.ssw_init(
        read.pack('c*'), read_len, mat.flatten.pack('c*'), n, score_size
      )
      LibSSW::Profile.new(ptr)
    end

    def init_destroy(profile)
      FFI.init_destroy(profile)
    end

    def ssw_align(prof, ref, ref_len, weight_gap0, weight_gapE, flag, filters, filterd, mask_len)
      ptr = FFI.ssw_align(
        prof, ref.pack('c*'), ref_len, weight_gap0, weight_gapE, flag, filters, filterd, mask_len
      )
      LibSSW::Align.new(ptr)
    end

    def align_destroy(align)
      FFI.align_destroy(align)
    end

    def mark_mismatch(ref_begin1, read_begin1, read_end1, ref, read, read_len, cigar, cigar_len)
      warn 'implementation: fiexme: **cigar' # FIXME
      FFI.mark_mismatch(
        ref_begin1, read_begin1, read_end1, ref.pack('c*'), read.pack('c*'), read_len, cigar, cigar_len.pack('l*')
      )
    end
  end
end
