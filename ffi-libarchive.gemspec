lib = File.expand_path("lib", __dir__)
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

  s.files = %w{ LICENSE } + Dir.glob("lib/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  s.require_paths = %w{lib}
  s.required_ruby_version = ">= 3.0"
  s.add_dependency "ffi", "~> 1.17"
end
