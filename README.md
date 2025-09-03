# ffi-libarchive

[![Build status](https://badge.buildkite.com/a6b96170c6257e384000f311fa0052cb7880762e06bc66c91e.svg)](https://buildkite.com/chef-oss/chef-ffi-libarchive-master-verify)
[![Gem Version](https://badge.fury.io/rb/ffi-libarchive.svg)](https://badge.fury.io/rb/ffi-libarchive)

**Umbrella Project**: [Chef Foundation](https://github.com/chef/chef-oss-practices/blob/master/projects/chef-foundation.md)

A Ruby FFI binding to [libarchive][0].

This library provides Ruby FFI bindings to the well-known [libarchive library](https://github.com/libarchive/libarchive).

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

- License:: Apache License, Version 2.0

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```