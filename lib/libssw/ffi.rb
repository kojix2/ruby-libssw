require 'fiddle/import'

module LibSSW
  module FFI
    extend Fiddle::Importer

    begin
      dlload LibSSW.ffi_lib
    rescue LoadError => e
      raise LoadError, "Could not find libssw shared library. \n#{e}"
    end

    class << self
      attr_reader :func_map

      def try_extern(signature, *opts)
        extern(signature, *opts)
      rescue StandardError => e
        warn "#{e.class.name}: #{e.message}"
      end

      def ffi_methods
        @ffi_methods ||= func_map.each_key.to_a
      end
    end
  end
end
