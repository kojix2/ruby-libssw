# frozen_string_literal: true

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

    Align = struct [
      'uint16_t score1',
      'uint16_t score2',
      'int32_t ref_begin1',
      'int32_t ref_end1',
      'int32_t read_begin1',
      'int32_t read_end1',
      'int32_t ref_end2',
      'uint32_t* cigar',
      'int32_t cigarLen'
    ]

    Profile = struct [
      'int32_t* byte', # __m128i* profile_byte;	// 0: none
      'int32_t* word', # __m128i* profile_word;	// 0: none
      'const int8_t* read',
      'const int8_t* mat',
      'int32_t readLen',
      'int32_t n',
      'uint8_t bias'
    ]

    # s_profile* ssw_init (const int8_t* read, const int32_t readLen, const int8_t* mat, const int32_t n, const int8_t score_size)
    try_extern 's_profile* ssw_init ('  \
               'const int8_t* read,'    \
               'int32_t readLen,'       \
               'const int8_t* mat,'     \
               'int32_t n,'             \
               'int8_t score_size)'

    try_extern 'void init_destroy (s_profile* p)'

    try_extern 's_align* ssw_align ('   \
               'const s_profile* prof,' \
               'const int8_t* ref,'     \
               'int32_t refLen,'        \
               'uint8_t weight_gapO,'   \
               'uint8_t weight_gapE,'   \
               'uint8_t flag,'          \
               'uint16_t filters,'      \
               'int32_t filterd,'       \
               'int32_t maskLen)'

    try_extern 'void align_destroy (s_align* a)'

    try_extern 'int32_t mark_mismatch (' \
               'int32_t ref_begin1,'     \
               'int32_t read_begin1,'    \
               'int32_t read_end1,'      \
               'const int8_t* ref,'      \
               'const int8_t* read,'     \
               'int32_t readLen,'        \
               'uint32_t** cigar,'       \
               'int32_t* cigarLen)'
  end
end
