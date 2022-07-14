---
title: 'ruby-libssw'
author:
  - 'kojix2'
date: 24 May 2022
bibliography: ruby-libssw.bib
header-includes:
  - \usepackage[margin=1in]{geometry}
---

# Summary

Ruby-libssw is the Ruby binding of libssw, a library that uses the Smith-Waterman algorithm to find the best pairwise alignment of two sequences. ruby-libssw was created using fiddle, the Ruby standard library. Ruby-libssw can be used to create local alignments of nucleotide and amino acid sequences in the Ruby language.

Code : [https://github.com/kojix2/ruby-libssw](https://github.com/kojix2/ruby-libssw)

# Statement of need

[@SSWLibrarySIMD]

# Benchmark

# Examples

```ruby
require 'libssw'
```

```ruby
ref_str  = "AAAAAAAAACGTTAAAAAAAAAA"
ref_int  = SSW::DNA.to_int_array(ref_str) 
# [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
```

```ruby
read_str1 = "ACGTT"
read_str2 = SSW::DNA.revcomp(read_str1)
# "AACGT"
read_int1 = SSW::DNA.to_int_array(read_str1)
# [0, 1, 2, 3, 3]
read_int2 = SSW::DNA.to_int_array(read_str2)
# [0, 0, 1, 2, 3]
```

```ruby
mat = SSW.create_scoring_matrix(SSW::DNA::Elements, 2, -2)
# mat = [2, -2, -2, -2,  0,
#       -2,  2, -2, -2,  0,
#       -2, -2,  2, -2,  0,
#       -2, -2, -2,  2,  0,
#        0,  0,  0,  0,  0]
```

```ruby
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
```

```ruby
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
```

```ruby
puts SSW.build_path(read_str1, ref_str, align1)
# 5M
# ACGTT
# |||||
# ACGTT
```

# Reference
