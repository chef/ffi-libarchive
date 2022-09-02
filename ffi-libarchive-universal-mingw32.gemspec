gemspec = eval(IO.read(File.expand_path("ffi-libarchive.gemspec", __dir__))) # rubocop: disable Security/Eval

gemspec.platform = Gem::Platform.new(%w{universal mingw32})

gemspec.files += Dir.glob("{distro}/**/*")

gemspec
