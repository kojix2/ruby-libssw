# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

# Don't add vendor directory to packages for distribution
task :remove_vendor_directory do
  if Dir.exist?('vendor')
    warn 'Removing the vender directory...'
    FileUtils.remove_dir('vendor')
  end
end

namespace :libssw do
  desc 'Compile libssw'
  task :build do
    Dir.chdir('Complete-Striped-Smith-Waterman-Library/src') do
      # macOS
      if RUBY_PLATFORM.match(/darwin/)
        sh 'gcc -Wall -O3 -pipe -fPIC -dynamiclib -rdynamic ssw.c ssw.h'
        FileUtils.mkdir_p('../../vendor')
        FileUtils.move('a.out', '../../vendor/libssw.dylib')
      # Linux
      else
        sh 'gcc -Wall -O3 -pipe -fPIC -shared -rdynamic -o libssw.so ssw.c ssw.h'
        FileUtils.mkdir_p('../../vendor')
        FileUtils.move('libssw.so', '../../vendor/libssw.so')
      end
      # May not work on Windows?
    end
  end
end

# c2ffi: Clang-based FFI wrapper generator
# https://github.com/rpav/c2ffi
# Not used in ruby-libssw project
namespace :c2ffi do
  desc 'Generate metadata files (JSON format) using c2ffi'
  task :generate do
    FileUtils.mkdir_p('codegen/c2ffilogs')
    header_files = FileList['Complete-Striped-Smith-Waterman-Library/src/*.h']
    header_files.each do |file|
      basename = File.basename(file, '.h')
      sh 'c2ffi' \
         " -o codegen/#{basename}.json" \
         " -M codegen/#{basename}.c #{file}" \
         " 2> codegen/c2ffilogs/#{basename}.log"
    end
  end

  desc 'Remove metadata files'
  task :remove do
    FileList['codegen/*.{json,c}', 'codegen/c2ffilogs/*.log'].each do |path|
      File.unlink(path) if File.exist?(path)
    end
  end
end
