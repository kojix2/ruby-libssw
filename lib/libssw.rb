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
                   File.expand_path(lib_name, ENV['LIBUIDIR'])
                 else
                   File.expand_path("../vendor/#{lib_name}", __dir__)
                 end

  require_relative 'libssw/ffi'

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
