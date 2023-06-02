gemspec = eval(IO.read(File.expand_path("ffi-libarchive.gemspec", __dir__))) # rubocop: disable Security/Eval

gemspec.platform =  if RUBY_VERSION.match(/2.7/)
                      Gem::Platform.new(%w{universal mingw32})
                    else
                      Gem::Platform.new(%w{universal mingw})
                    end

gemspec.files += Dir.glob("{distro}/**/*")

gemspec
