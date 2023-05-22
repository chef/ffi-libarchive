gemspec = eval(IO.read(File.expand_path("ffi-libarchive.gemspec", __dir__))) # rubocop: disable Security/Eval

if RUBY_VERSION.match(/2.7/)
  gemspec.platform = Gem::Platform.new(%w{universal mingw32})
else
  gemspec.platform = Gem::Platform.new(%w{universal mingw})
end

gemspec.files += Dir.glob("{distro}/**/*")

gemspec
