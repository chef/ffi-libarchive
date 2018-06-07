#!/usr/bin/env rake

require "bundler/setup"
require "bundler/gem_tasks"
require "chefstyle"
require "rubocop/rake_task"
require "rake/testtask"

namespace :style do
  desc "Run Ruby style checks"
  RuboCop::RakeTask.new(:ruby)
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/test_ffi-libarchive.rb"]
end

desc "Run all style checks"
task style: ["style:ruby"]

desc "Run style & unit tests on Travis"
task travis: %w{style test}

# Default
desc "Run style, unit"
task default: %w{style test}
