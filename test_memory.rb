#!/usr/bin/env ruby
# frozen_string_literal: true

# This script tests that the garbage collection workaround is working correctly.
# It creates many profiles and alignments, forcing GC between operations.

require 'libssw'

def stress_test
  puts 'Starting memory stress test...'

  ref_str  = 'AAAAAAAAACGTTAAAAAAAAAA'
  ref_int  = SSW::DNA.to_int_array(ref_str)
  read_str1 = 'ACGTT'
  read_int1 = SSW::DNA.to_int_array(read_str1)
  mat = SSW.create_scoring_matrix(SSW::DNA::Elements, 2, -2)

  100.times do |i|
    # Create profile
    profile = SSW.init(read_int1, mat)

    # Force garbage collection to try to trigger any memory issues
    GC.start

    # Use the profile
    align = SSW.align(profile, ref_int, 3, 1, 1, 0, 0)

    # Verify the result
    unless align.score1 == 10 && align.cigar_string == '5M'
      puts "ERROR at iteration #{i}: score1=#{align.score1}, cigar=#{align.cigar_string}"
      exit 1
    end

    # Force GC again
    GC.start

    # Clean up
    SSW.init_destroy(profile)

    print '.' if i % 10 == 0
  end

  puts "\n✓ Completed 100 iterations successfully!"
  puts 'Memory stress test passed - no segmentation faults!'
end

def test_profile_persistence
  puts "\nTesting profile persistence across GC..."

  read_str = 'ACGTT'
  read_int = SSW::DNA.to_int_array(read_str)
  mat = SSW.create_scoring_matrix(SSW::DNA::Elements, 2, -2)

  # Create a profile
  profile = SSW.init(read_int, mat)

  # Store the profile's data
  original_read = profile.read.dup
  original_mat = profile.mat.dup

  # Force multiple GC cycles
  5.times do
    GC.start
    sleep 0.01
  end

  # Verify the profile still has correct data
  if profile.read == original_read && profile.mat == original_mat
    puts '✓ Profile data survived garbage collection!'
  else
    puts 'ERROR: Profile data was corrupted!'
    exit 1
  end

  # Now use it for alignment
  ref_str = 'AAAAAAAAACGTTAAAAAAAAAA'
  ref_int = SSW::DNA.to_int_array(ref_str)
  align = SSW.align(profile, ref_int, 3, 1, 1, 0, 0)

  if align.score1 == 10 && align.cigar_string == '5M'
    puts '✓ Profile still works correctly after GC!'
  else
    puts 'ERROR: Alignment failed after GC!'
    exit 1
  end

  SSW.init_destroy(profile)
end

def test_concurrent_profiles
  puts "\nTesting multiple concurrent profiles..."

  mat = SSW.create_scoring_matrix(SSW::DNA::Elements, 2, -2)
  ref_str = 'AAAAAAAAACGTTAAAAAAAAAA'
  ref_int = SSW::DNA.to_int_array(ref_str)

  sequences = %w[ACGTT AACGT CGTTA GTTAA]
  profiles = sequences.map do |seq|
    SSW.init(SSW::DNA.to_int_array(seq), mat)
  end

  # Force GC while all profiles exist
  GC.start

  # Use all profiles
  results = profiles.map do |profile|
    align = SSW.align(profile, ref_int, 3, 1, 1, 0, 0)
    [align.score1, align.cigar_string]
  end

  # Verify all results are correct
  if results.all? { |score, _| score == 10 }
    puts '✓ All concurrent profiles worked correctly!'
  else
    puts 'ERROR: Some profiles failed!'
    puts results.inspect
    exit 1
  end

  # Clean up
  profiles.each { |p| SSW.init_destroy(p) }
end

# Run all tests
stress_test
test_profile_persistence
test_concurrent_profiles

puts "\n" + '=' * 50
puts 'All memory management tests passed! ✓'
puts '=' * 50
