# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ffi-libarchive/version"

Gem::Specification.new do |s|
  s.name = "ffi-libarchive"
  s.version = Archive::VERSION
  s.authors = ["John Bellone", "Jamie Winsor", "Frank Fischer"]
  s.email = %w{jbellone@bloomberg.net jamie@vialstudios.com frank-fischer@shadow-soft.de}
  s.description = "A Ruby FFI binding to libarchive."
  s.summary = s.description
  s.homepage = "https://github.com/chef/ffi-libarchive"
  s.license = "Apache-2.0"

  s.files = %w{ Gemfile Rakefile README.md LICENSE VERSION } + Dir.glob("{lib,test}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) } + Dir.glob("*.gemspec")
  s.require_paths = %w{lib}
  s.required_ruby_version = ">= 2.4.0"

  s.add_dependency "ffi", "~> 1.0"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "test-unit"
end
