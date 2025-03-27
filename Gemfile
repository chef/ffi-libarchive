source 'https://rubygems.org'

gemspec

group :test do
  gem 'cookstyle'
  gem 'rspec', '~> 3.0'
  gem 'rake'
  gem 'test-unit'
  gem 'ffi'
end

group :debug do
  gem 'pry'
  gem 'pry-byebug'
  gem 'rb-readline'
end

# These lines added for Windows (x64) development only.
# For ffi-libarchive to function during development on Windows we need the
# binaries in the RbConfig::CONFIG["bindir"]
#
# We copy (and overwrite) these files every time "bundle <exec|install>" is
# executed, just in case they have changed.
if RUBY_PLATFORM =~ /mswin|mingw|windows/
  instance_eval do
    ruby_exe_dir = RbConfig::CONFIG['bindir']
    assemblies = Dir.glob(File.expand_path('distro/ruby_bin_folder', Dir.pwd) + '/*.dll')
    FileUtils.cp_r assemblies, ruby_exe_dir, verbose: false unless ENV['_BUNDLER_LIBARCHIVE_DLLS_COPIED']
    ENV['_BUNDLER_LIBARCHIVE_DLLS_COPIED'] = '1'
  end
end
