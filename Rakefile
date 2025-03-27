require 'bundler'
Bundler::GemHelper.install_tasks name: 'ffi-libarchive'

# require "bundler/gem_tasks"
require 'rake/testtask'

begin
  require 'cookstyle'
  require 'rubocop/rake_task'
  desc 'Run Cookstyle tests'
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ['--display-cop-names', '--no-color']
  end
rescue LoadError
  puts 'cookstyle gem is not installed. bundle install first to make sure all dependencies are installed.'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/test_ffi-libarchive.rb']
end

desc 'Run style & unit tests on Travis'
task travis: %w(test style)

# Default
desc 'Run style, unit'
task default: %w(test style)
