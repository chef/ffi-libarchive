require 'ffi-libarchive'
require 'tmpdir'
require 'test/unit'

class TS_ReadArchive < Test::Unit::TestCase

    CONTENT_SPEC =
        [
         ['test/', 'directory', 0755, nil ],
         ['test/b/', 'directory', 0755, nil ],
         ['test/b/c/', 'directory', 0755, nil ],
         ['test/b/c/c.dat', 'file', 0600, "\266\262\v_\266\243\305\3601\204\277\351\354\265\003\036\036\365f\377\210\205\032\222\346\370b\360u\032Y\301".b ],
         ['test/b/c/d/', 'directory', 0711, nil ],
         ['test/b/c/d/d.dat', 'symbolic_link', 0777, "../c.dat" ],
         ['test/b/b.dat', 'file', 0640, "s&\245\354(M\331=\270\000!s\355\240\252\355'N\304\343\bY\317\t\274\210\3128\321\347\234!".b ],
         ['test/a.dat', 'file', 0777, "\021\216\231Y\354\236\271\372\336\213\224R\211{D{\277\262\304\211xu\330\\\275@~\035\vSRM".b ]
        ]

    def setup
        File.open('data/test.tar.gz', 'rb') do |f|
            @archive_content = f.read
        end
    end


    def test_read_tar_gz_from_file
        Archive.read_open_filename('data/test.tar.gz') do |ar|
            verify_content(ar)
        end
    end

    def test_read_tar_gz_from_file_with_external_gunzip
        Archive.read_open_filename('data/test.tar.gz', 'gunzip') do |ar|
            verify_content(ar)
        end
    end

    def test_read_tar_gz_from_memory
        Archive.read_open_memory(@archive_content) do |ar|
            verify_content(ar)
        end
    end

    def test_read_tar_gz_from_memory_with_external_gunzip
        Archive.read_open_memory(@archive_content, 'gunzip') do |ar|
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
            content += alphabet[index,1]
        end

        Dir.mktmpdir do |dir|
            Archive.write_open_filename(dir + '/test.tar.gz',
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

            Archive.read_open_filename(dir + '/test.tar.gz') do |ar|
                entry = ar.next_header
                data = ar.read_data

                assert_equal entry_size, data.size
                assert_equal content.size, data.size
                assert_equal content, data
            end

            Archive.read_open_filename(dir + '/test.tar.gz') do |ar|
                entry = ar.next_header
                data = ""
                ar.read_data(128) { |chunk| data += chunk }

                assert_equal content, data
            end
        end
    end

    private

    def verify_content(ar)
        content_spec_idx = 0

        while entry = ar.next_header
            expect_pathname, expect_type, expect_mode, expect_content =\
            CONTENT_SPEC[content_spec_idx]

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
