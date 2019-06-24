# ffi-libarchive

[![Build status](https://badge.buildkite.com/a6b96170c6257e384000f311fa0052cb7880762e06bc66c91e.svg)](https://buildkite.com/chef-oss/chef-ffi-libarchive-master-verify)
[![Gem Version](https://badge.fury.io/rb/ffi-libarchive.svg)](https://badge.fury.io/rb/ffi-libarchive)

**Umbrella Project**: [Chef Foundation](https://github.com/chef/chef-oss-practices/blob/master/projects/chef-foundation.md)

**Project State**: [Active](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md#active)

**Issues [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

**Pull Request [Response Time Maximum](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md)**: 14 days

A Ruby FFI binding to [libarchive][0].

This library provides Ruby FFI bindings to the well-known
[libarchive library][0].

## Installation

Ensure that you have libarchive installed. On Debian/Ubuntu:

```sh
apt install libarchive13
```

On macOS with Homebrew:
```sh
brew install libarchive
```

Add this line to your application's Gemfile:

```ruby
gem 'ffi-libarchive'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install ffi-libarchive
```

## Usage

To extract an archive into the current directory:

```ruby
flags = Archive::EXTRACT_PERM
reader = Archive::Reader.open_filename('/path/to/archive.tgz')

reader.each_entry do |entry|
  reader.extract(entry, flags.to_i)
end
reader.close
```

To create a gzipped tar archive:

```ruby
Archive.write_open_filename('my.tgz', Archive::COMPRESSION_GZIP, Archive::FORMAT_TAR_PAX_RESTRICTED) do |tar|
  content = File.read 'some_path'
  size = content.size
  tar.new_entry do |e|
    e.pathname = 'some_path'
    e.size = size
    e.filetype = Archive::Entry::FILE
    tar.write_header e
    tar.write_data content
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/chef/ffi-libarchive>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Community Guidelines](https://docs.chef.io/community_guidelines.html) code of conduct.

## License

The gem is available as open source under the terms of the Apache License, v2

[0]: https://github.com/libarchive/libarchive
