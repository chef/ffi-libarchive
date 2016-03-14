#!/usr/bin/env rake

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'

namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby)
end

desc 'Run all style checks'
task style: ['style:ruby']

desc 'Run style & unit tests on Travis'
task travis: %w(style)

# Default
desc 'Run style, unit, and Vagrant-based integration tests'
task default: %w(style)
