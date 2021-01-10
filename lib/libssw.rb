# frozen_string_literal: true

require 'forwardable'
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

  Align   = FFI::Align
  Profile = FFI::Profile
  class << self
    extend Forwardable
    def_delegators 'LibSSW::FFI',
                   :ssw_init,
                   :init_destroy,
                   :ssw_align,
                   :align_destroy,
                   :mark_mismatch
  end
end
