# frozen_string_literal: true

module SSW
  module AASeq
    AAELEMENTS = ['A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G',
                  'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S',
                  'T', 'W', 'Y', 'V', 'B', 'Z', 'X', '*'].freeze

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
               '*' => 23 }.freeze

    INT2AA = { 0 => 'A', 1 => 'R', 2 => 'N', 3 => 'D',
               4 => 'C', 5 => 'Q', 6 => 'E', 7 => 'G',
               8 => 'H', 9 => 'I', 10 => 'L', 11 => 'K',
               12 => 'M', 13 => 'F', 14 => 'P', 15 => 'S',
               16 => 'T', 17 => 'W', 18 => 'Y', 19 => 'V',
               20 => 'B', 21 => 'Z', 22 => 'X', 23 => '*' }.freeze

    module_function

    # Transform amino acid sequence into numerical sequence.
    # @param seq [String] amin acid sequence
    # @return [Array] int array
    # @example
    #   SSW::AASeq.to_int_array("ARND") #=> [0, 1, 2, 3]

    def to_int_array(seq)
      raise ArgumentError, 'seq must be a string' unless seq.is_a? String

      seq.each_char.map do |base|
        AA2INT[base] || AA2INT['*']
      end
    end

    # Transform numerical sequence into amino acid sequence.
    # @param arr [Array] int array
    # @return [String] amino acid sequence
    # @example
    #   SSW::AASeq.from_int_array([0, 1, 2, 3]) #=> "ARND"

    def from_int_array(arr)
      raise ArgumentError, 'arr must be an Array' unless arr.is_a? Array

      arr.map do |i|
        INT2AA[i] || '*'
      end.join
    end
  end
end
