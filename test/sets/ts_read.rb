require "ffi-libarchive"
require "tmpdir"
require "test/unit"

class TS_ReadArchive < Test::Unit::TestCase

  CONTENT_SPEC = [
    ["test/", "directory", 0755, nil ],
    ["test/b/", "directory", 0755, nil ],
    ["test/b/c/", "directory", 0755, nil ],
    ["test/b/c/c.dat", "file", 0600, "\266\262\v_\266\243\305\3601\204\277\351\354\265\003\036\036\365f\377\210\205\032\222\346\370b\360u\032Y\301".b ],
    ["test/b/c/d/", "directory", 0711, nil ],
    ["test/b/c/d/d.dat", "symbolic_link", 0777, "../c.dat" ],
    ["test/b/b.dat", "file", 0640, "s&\245\354(M\331=\270\000!s\355\240\252\355'N\304\343\bY\317\t\274\210\3128\321\347\234!".b ],
    ["test/a.dat", "file", 0777, "\021\216\231Y\354\236\271\372\336\213\224R\211{D{\277\262\304\211xu\330\\\275@~\035\vSRM".b ],
  ].freeze

  def setup
    File.open("data/test.tar.gz", "rb") do |f|
      @archive_content = f.read
    end
  end

  def test_read_tar_gz_from_file
    Archive.read_open_filename("data/test.tar.gz") do |ar|
      verify_content(ar)
    end
  end

  def test_read_tar_gz_from_file_with_external_gunzip
    Archive.read_open_filename("data/test.tar.gz", "gunzip") do |ar|
      verify_content(ar)
    end
  end

  def test_read_tar_gz_from_memory
    Archive.read_open_memory(@archive_content) do |ar|
      verify_content(ar)
    end
  end

  def test_read_tar_gz_from_memory_with_external_gunzip
    Archive.read_open_memory(@archive_content, "gunzip") do |ar|
      verify_content(ar)
    end
  end

  def test_read_entry_bigger_than_internal_buffer
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    entry_size = 1024 * 4 - 3

    srand
    content = ""
    1.upto(entry_size) do |i|
      index = rand(alphabet.size)
      content += alphabet[index, 1]
    end

    Dir.mktmpdir do |dir|
      Archive.write_open_filename(dir + "/test.tar.gz",
        Archive::COMPRESSION_BZIP2, Archive::FORMAT_TAR) do |ar|
          ar.new_entry do |entry|
            entry.pathname = "chubby.dat"
            entry.mode = 0666
            entry.filetype = Archive::Entry::FILE
            entry.atime = Time.now.to_i
            entry.mtime = Time.now.to_i
            entry.size = entry_size
            ar.write_header(entry)
            ar.write_data(content)
          end
        end

      Archive.read_open_filename(dir + "/test.tar.gz") do |ar|
        ar.next_header
        data = ar.read_data

        assert_equal entry_size, data.size
        assert_equal content.size, data.size
        assert_equal content, data
      end

      Archive.read_open_filename(dir + "/test.tar.gz") do |ar|
        ar.next_header
        data = ""
        ar.read_data(128) { |chunk| data += chunk }

        assert_equal content, data
      end
    end
  end

  def test_extract_no_additional_flags
    Dir.mktmpdir do |dir|
      Archive.read_open_filename("data/test.tar.gz") do |ar|
        Dir.chdir(dir) do
          ar.each_entry do |e|
            ar.extract(e)
            assert_not_equal File.mtime(e.pathname), e.mtime
          end
        end
      end
    end
  end

  def test_extract_extract_time
    Dir.mktmpdir do |dir|
      Archive.read_open_filename("data/test.tar.gz") do |ar|
        Dir.chdir(dir) do
          ar.each_entry do |e|
            ar.extract(e, Archive::EXTRACT_TIME.to_i)
            next if e.directory? || e.symbolic_link?

            assert_equal File.mtime(e.pathname), e.mtime
          end
        end
      end
    end
  end

  def test_read_from_stream_with_proc
    fp = File.open("data/test.tar.gz", "rb")
    reader = Proc.new do
      fp.read(32)
    end

    Archive.read_open_stream(reader) do |ar|
      verify_content(ar)
    end
  end

  class TestReader
    def initialize
      @fp = File.open("data/test.tar.gz", "rb")
    end

    def call
      @fp.read(32)
    end
  end

  def test_read_from_stream_with_object
    Archive.read_open_stream(TestReader.new) do |ar|
      verify_content(ar)
    end
  end

  class SkipNSeekTestReader < TestReader
    attr_reader :skip_called, :seek_called

    def initialize
      @fp = File.open("data/test.zip")
    end

    def skip(offset)
      @skip_called = true
      orig_pos = fp.tell
      fp.seek(offset, :CUR)
      fp.tell - orig_pos
    end

    def seek(offset, whence)
      @seek_called = true
      @fp.seek(offset, whence)
      @fp.tell
    end
  end

  def test_read_from_stream_with_skip_seek_object
    expect_pathname, expect_type, _, expect_content = CONTENT_SPEC[6]
    verified = false
    reader = SkipNSeekTestReader.new

    Archive.read_open_stream(reader) do |ar|
      ar.each_entry do |entry|
        next unless entry.pathname == expect_pathname
        verified = true

        assert_equal expect_pathname, entry.pathname
        assert_equal entry.send("#{expect_type}?"), true
        # Skip verifying file mode; Zip files don't store it.

        assert entry.file?
        content = ar.read_data(1024)
        assert_equal expect_content, content
      end
    end

    assert verified
    assert reader.skip_called
    assert reader.seek_called
  end

  private

  def verify_content(ar)
    content_spec_idx = 0

    while (entry = ar.next_header)
      expect_pathname, expect_type, expect_mode, expect_content = CONTENT_SPEC[content_spec_idx]

      assert_equal expect_pathname, entry.pathname
      assert_equal entry.send("#{expect_type}?"), true
      assert_equal expect_mode, (entry.mode & 07777)

      if entry.symbolic_link?
        assert_equal expect_content, entry.symlink
      elsif entry.file?
        content = ar.read_data(1024)
        assert_equal expect_content, content
      end

      content_spec_idx += 1
    end
  end

end
