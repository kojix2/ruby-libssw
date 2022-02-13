# ruby-libssw

![test](https://github.com/kojix2/ruby-libssw/workflows/CI/badge.svg)
[![Gem Version](https://img.shields.io/gem/v/libssw?color=brightgreen)](https://rubygems.org/gems/libssw)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://rubydoc.info/gems/libssw)
[![DOI](https://zenodo.org/badge/328163622.svg)](https://zenodo.org/badge/latestdoi/328163622)

:checkered_flag: [libssw](https://github.com/mengyao/Complete-Striped-Smith-Waterman-Library) - fast SIMD parallelized implementation of the Smith-Waterman algorithm - for Ruby

## Installation

```ssh
gem install libssw
```

Set the environment variable `LIBSSWDIR` to specify the location of the shared library.
For example, on Ubuntu, you can use libssw in the following way.

```
sudo apt install libssw-dev
export LIBSSWDIR=/usr/lib/x86_64-linux-gnu/ # libssw.so
```

### Installing from source

When installing from source code using the following steps, the shared library `libssw.so` or `libssw.dylib` will be packed in the Ruby gem. In this case, the environment variable `LIBSSWDIR` is not required. 

```sh
git clone --recursive https://github.com/kojix2/ruby-libssw
bundle exec rake libssw:build
bundle exec rake install
```

ruby-libssw does not support Windows.

## Usage

```ruby
require 'libssw'

ref_str  = "AAAAAAAAACGTTAAAAAAAAAA"
ref_int  = SSW::DNA.to_int_array(ref_str) 
# [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

read_str1 = "ACGTT"
read_str2 = SSW::DNA.revcomp(read_str1)
# "AACGT"
read_int1 = SSW::DNA.to_int_array(read_str1)
# [0, 1, 2, 3, 3]
read_int2 = SSW::DNA.to_int_array(read_str2)
# [0, 0, 1, 2, 3]

mat = SSW.create_scoring_matrix(SSW::DNA::Elements, 2, -2)
# mat = [2, -2, -2, -2,  0,
#       -2,  2, -2, -2,  0,
#       -2, -2,  2, -2,  0,
#       -2, -2, -2,  2,  0,
#        0,  0,  0,  0,  0]

profile1 = SSW.init(read_int1, mat)
align1   = SSW.align(profile1, ref_int, 3, 1, 1, 0, 0)
pp align1.to_h
# {
#  :score1       => 10,
#  :score2       => 0,
#  :ref_begin1   => 8,
#  :ref_end1     => 12,
#  :read_begin1  => 0,
#  :read_end1    => 4,
#  :ref_end2     => 0,
#  :cigar        => [80],
#  :cigar_len    => 1,
#  :cigar_string => "5M"
# }

profile2 = SSW.init(read_int2, mat)
align2   = SSW.align(profile2, ref_int, 3, 1, 1, 0, 0)
pp align2.to_h
# {
#  :score1       => 10,
#  :score2       => 0,
#  :ref_begin1   => 7,
#  :ref_end1     => 11,
#  :read_begin1  => 0,
#  :read_end1    => 4,
#  :ref_end2     => 0,
#  :cigar        => [80],
#  :cigar_len    => 1,
#  :cigar_string => "5M"
# }

puts SSW.build_path(read_str1, ref_str, align1)
# 5M
# ACGTT
# |||||
# ACGTT
```

## APIs

See [API Documentation](https://rubydoc.info/gems/libssw).

```markdown
* SSW module
  * SSW.init
  * SSW.init_destroy
  * SSW.align
  * SSW.align_destroy
  * SSW.mark_mismatch
  * SSW.create_scoring_matrix
  * SSW.build_path
  
  * Profile class
    * attributes
      * read, mat, read_len, n, bias

  * Align class
    * attributes
      * score1, score2, ref_begin1, ref_end1, read_begin1, read_end1, ref_end2
        cigar, cigar_len, cigar_string
  
  * DNA module
    * DNA.to_int_array
    * DNA.from_int_array
    * revcomp

  * AASeq module
    * AASeq.to_int_array
    * AASeq.from_int_array

  * BLOSUM62
  * BLOSUM50
```

## Development

```sh
git clone --recursive https://github.com/kojix2/ruby-libssw
bundle exec rake libssw:build
bundle exec rake test
```

    Do you need commit rights to my repository?
    Do you want to get admin rights and take over the project?
    If so, please feel free to contact me @kojix2.

## Contributing

* [Report bugs](https://github.com/kojix2/ruby-libssw/issues)
* Fix bugs and [submit pull requests](https://github.com/kojix2/ruby-libssw/pulls)
* Write, clarify, or fix documentation
* English corrections are welcome
* Suggest or add new features

## License

* [MIT License](https://opensource.org/licenses/MIT).
