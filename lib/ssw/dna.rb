# frozen_string_literal: true

module SSW
  module DNA
    Elements = %w[A C G T N].freeze

    DNA2INT = { 'A' => 0, 'a' => 0,
                'C' => 1, 'c' => 1,
                'G' => 2, 'g' => 2,
                'T' => 3, 't' => 3,
                'N' => 4, 'n' => 4 }.freeze

    INT2DNA = { 0 => 'A', 1 => 'C', 2 => 'G', 3 => 'T', 4 => 'N' }.freeze

    # reverse complement
    DNARC = { 'A' => 'T',
              'C' => 'G',
              'G' => 'C',
              'T' => 'A',
              'N' => 'N',
              'a' => 'T',
              'c' => 'G',
              'g' => 'C',
              't' => 'A',
              'n' => 'N' }.freeze

    module_function

    # Transform DNA sequence into numerical sequence.
    # @param seq [String] dna sequence
    # @return [Array] int array
    # @example
    #   SSW::DNA.to_int_array("TCGA") #=> [3, 1, 2, 0]

    def to_int_array(seq)
      raise ArgumentError, 'seq must be a string' unless seq.is_a? String

      seq.each_char.map do |base|
        DNA2INT[base] || DNA2INT['N']
      end
    end

    # Transform numerical sequence into DNA sequence.
    # @param arr [Array] int array
    # @retrun [String] dna sequence
    # @example
    #   SSW::DNA.from_int_array([3, 1, 2, 0]) #=> "TCGA"

    def from_int_array(arr)
      raise ArgumentError, 'arr must be an Array' unless arr.is_a? Array

      arr.map do |i|
        INT2DNA[i] || 'N'
      end.join
    end

    # reverse complement
    # @param seq [String] sequence
    # @return [String] reverse complement
    # @example
    #   SSW::DNA.revcomp("TCGAT") #=> "ATCGA"

    def revcomp(seq)
      seq.each_char.map do |base|
        DNARC[base]
      end.join.reverse
    end
  end
end
