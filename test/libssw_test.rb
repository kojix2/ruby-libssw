# frozen_string_literal: true

require_relative 'test_helper'

class LibsswTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil LibSSW::VERSION
  end

  def test_align_struct_malloc
    assert_instance_of LibSSW::FFI::Align, LibSSW::FFI::Align.malloc
    assert_instance_of LibSSW::Align, LibSSW::Align.malloc
  end

  def test_profile_struct_malloc
    assert_instance_of LibSSW::FFI::Profile, LibSSW::FFI::Profile.malloc
    assert_instance_of LibSSW::Profile, LibSSW::Profile.malloc
  end
end
