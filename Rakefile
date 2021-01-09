# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

namespace :libssw do
  desc "Compile libssw"
  task :compile do
    Dir.chdir("Complete-Striped-Smith-Waterman-Library/src") do
      system "gcc -Wall -O3 -pipe -fPIC -shared -rdynamic -o libssw.so ssw.c ssw.h"
      FileUtils.mkdir_p("../../vendor")
      FileUtils.move("libssw.so", "../../vendor/libssw.so") # May not work on Windows or Mac?
    end
  end
end