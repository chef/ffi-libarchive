require 'ffi'

module Archive

    module C
        extend FFI::Library
        ffi_lib ["archive", "libarchive.so.2"]

        attach_function :archive_version_number, [], :int
        attach_function :archive_version_string, [], :string
        attach_function :archive_error_string, [:pointer], :string

        attach_function :archive_read_new, [], :pointer
        attach_function :archive_read_open_filename, [:pointer, :string, :size_t], :int
        attach_function :archive_read_open_memory, [:pointer, :pointer, :size_t], :int
        attach_function :archive_read_support_compression_program, [:pointer, :string], :int
        attach_function :archive_read_support_compression_all, [:pointer], :int
        attach_function :archive_read_support_format_all, [:pointer], :int
        # TODO: this function has been renamed to :archive_read_free in libarchive 3.0
        attach_function :archive_read_finish, [:pointer], :int
        attach_function :archive_read_extract, [:pointer, :pointer, :int], :int
        attach_function :archive_read_header_position, [:pointer], :int
        attach_function :archive_read_next_header, [:pointer, :pointer], :int
        attach_function :archive_read_data, [:pointer, :pointer, :size_t], :size_t
        attach_function :archive_read_data_into_fd, [:pointer, :int], :int

        attach_function :archive_write_open_filename, [:pointer, :string], :int
        attach_function :archive_write_open_memory, [:pointer, :pointer, :size_t, :pointer], :int

        attach_function :archive_entry_atime, [:pointer], :time_t
        attach_function :archive_entry_atime_nsec, [:pointer, :time_t, :long], :void
        attach_function :archive_entry_atime_is_set, [:pointer], :int
        attach_function :archive_entry_set_atime, [:pointer], :int
        attach_function :archive_entry_unset_atime, [:pointer], :int
        attach_function :archive_entry_birthtime, [:pointer], :time_t
        attach_function :archive_entry_birthtime_nsec, [:pointer, :time_t, :long], :void
        attach_function :archive_entry_birthtime_is_set, [:pointer], :int
        attach_function :archive_entry_set_birthtime, [:pointer], :int
        attach_function :archive_entry_unset_birthtime, [:pointer], :int
        attach_function :archive_entry_ctime, [:pointer], :time_t
        attach_function :archive_entry_ctime_nsec, [:pointer, :time_t, :long], :void
        attach_function :archive_entry_ctime_is_set, [:pointer], :int
        attach_function :archive_entry_set_ctime, [:pointer], :int
        attach_function :archive_entry_unset_ctime, [:pointer], :int
        attach_function :archive_entry_mtime, [:pointer], :time_t
        attach_function :archive_entry_mtime_nsec, [:pointer, :time_t, :long], :void
        attach_function :archive_entry_mtime_is_set, [:pointer], :int
        attach_function :archive_entry_set_mtime, [:pointer], :int
        attach_function :archive_entry_unset_mtime, [:pointer], :int
        attach_function :archive_entry_dev, [:pointer], :dev_t
        attach_function :archive_entry_set_dev, [:pointer, :dev_t], :void
        attach_function :archive_entry_devmajor, [:pointer], :dev_t
        attach_function :archive_entry_set_devmajor, [:pointer, :dev_t], :void
        attach_function :archive_entry_devminor, [:pointer], :dev_t
        attach_function :archive_entry_set_devminor, [:pointer, :dev_t], :void
        attach_function :archive_entry_filetype, [:pointer], :mode_t
        attach_function :archive_entry_set_filetype, [:pointer, :mode_t], :void
        attach_function :archive_entry_fflags, [:pointer, :pointer, :pointer], :void
        attach_function :archive_entry_set_fflags, [:pointer, :ulong, :ulong], :void
        attach_function :archive_entry_fflags_text, [:pointer], :string
        attach_function :archive_entry_gid, [:pointer], :gid_t
        attach_function :archive_entry_set_gid, [:pointer, :gid_t], :void
        attach_function :archive_entry_gname, [:pointer], :string
        attach_function :archive_entry_set_gname, [:pointer, :string], :void
        attach_function :archive_entry_hardlink, [:pointer], :string
        attach_function :archive_entry_set_hardlink, [:pointer, :string], :void
        attach_function :archive_entry_set_link, [:pointer, :string], :void
        attach_function :archive_entry_ino, [:pointer], :ino_t
        attach_function :archive_entry_set_ino, [:pointer, :ino_t], :void
        attach_function :archive_entry_mode, [:pointer], :mode_t
        attach_function :archive_entry_set_mode, [:pointer, :mode_t], :void
        attach_function :archive_entry_set_perm, [:pointer, :mode_t], :void
        attach_function :archive_entry_nlink, [:pointer], :uint
        attach_function :archive_entry_set_nlink, [:pointer, :uint], :void
        attach_function :archive_entry_pathname, [:pointer], :string
        attach_function :archive_entry_set_pathname, [:pointer, :string], :void
        attach_function :archive_entry_rdev, [:pointer], :dev_t
        attach_function :archive_entry_set_rdev, [:pointer, :dev_t], :void
        attach_function :archive_entry_rdevmajor, [:pointer], :dev_t
        attach_function :archive_entry_set_rdevmajor, [:pointer, :dev_t], :void
        attach_function :archive_entry_rdevminor, [:pointer], :dev_t
        attach_function :archive_entry_set_rdevminor, [:pointer, :dev_t], :void
        attach_function :archive_entry_size, [:pointer], :int64_t
        attach_function :archive_entry_set_size, [:pointer, :int64_t], :void
        attach_function :archive_entry_unset_size, [:pointer], :void
        attach_function :archive_entry_size_is_set, [:pointer], :int
        attach_function :archive_entry_sourcepath, [:pointer], :string
        attach_function :archive_entry_strmode, [:pointer], :string
        attach_function :archive_entry_symlink, [:pointer], :string
        attach_function :archive_entry_set_symlink, [:pointer, :string], :void
        attach_function :archive_entry_uid, [:pointer], :uid_t
        attach_function :archive_entry_set_uid, [:pointer, :uid_t], :void
        attach_function :archive_entry_uname, [:pointer], :string
        attach_function :archive_entry_set_uname, [:pointer, :string], :void
        attach_function :archive_entry_copy_fflags_text, [:pointer, :string], :string
        attach_function :archive_entry_copy_gname, [:pointer, :string], :string
        attach_function :archive_entry_copy_uname, [:pointer, :string], :string
        attach_function :archive_entry_copy_hardlink, [:pointer, :string], :string
        attach_function :archive_entry_copy_link, [:pointer, :string], :string
        attach_function :archive_entry_copy_symlink, [:pointer, :string], :string
        attach_function :archive_entry_copy_sourcepath, [:pointer, :string], :string

        OK     = 0
        RETRY  = (-10)
        WARN   = (-20)
        FAILED = (-25)
        FATAL  = (-30)

        DATA_BUFFER_SIZE = 2**16
    end

    COMPRESSION_NONE     = 0
    COMPRESSION_GZIP     = 1
    COMPRESSION_BZIP2    = 2
    COMPRESSION_COMPRESS = 3
    COMPRESSION_PROGRAM  = 4
    COMPRESSION_LZMA     = 5
    COMPRESSION_XZ       = 6
    COMPRESSION_UU       = 7
    COMPRESSION_RPM      = 8

    FORMAT_BASE_MASK           = 0xff0000
    FORMAT_CPIO                = 0x10000
    FORMAT_CPIO_POSIX          = (FORMAT_CPIO | 1)
    FORMAT_CPIO_BIN_LE         = (FORMAT_CPIO | 2)
    FORMAT_CPIO_BIN_BE         = (FORMAT_CPIO | 3)
    FORMAT_CPIO_SVR4_NOCRC     = (FORMAT_CPIO | 4)
    FORMAT_CPIO_SVR4_CRC       = (FORMAT_CPIO | 5)
    FORMAT_SHAR                = 0x20000
    FORMAT_SHAR_BASE           = (FORMAT_SHAR | 1)
    FORMAT_SHAR_DUMP           = (FORMAT_SHAR | 2)
    FORMAT_TAR                 = 0x30000
    FORMAT_TAR_USTAR           = (FORMAT_TAR | 1)
    FORMAT_TAR_PAX_INTERCHANGE = (FORMAT_TAR | 2)
    FORMAT_TAR_PAX_RESTRICTED  = (FORMAT_TAR | 3)
    FORMAT_TAR_GNUTAR          = (FORMAT_TAR | 4)
    FORMAT_ISO9660             = 0x40000
    FORMAT_ISO9660_ROCKRIDGE   = (FORMAT_ISO9660 | 1)
    FORMAT_ZIP                 = 0x50000
    FORMAT_EMPTY               = 0x60000
    FORMAT_AR                  = 0x70000
    FORMAT_AR_GNU              = (FORMAT_AR | 1)
    FORMAT_AR_BSD              = (FORMAT_AR | 2)
    FORMAT_MTREE               = 0x80000
    FORMAT_RAW                 = 0x90000
    FORMAT_XAR                 = 0xA0000

    EXTRACT_OWNER              = (0x0001)
    EXTRACT_PERM               = (0x0002)
    EXTRACT_TIME               = (0x0004)
    EXTRACT_NO_OVERWRITE       = (0x0008)
    EXTRACT_UNLINK             = (0x0010)
    EXTRACT_ACL                = (0x0020)
    EXTRACT_FFLAGS             = (0x0040)
    EXTRACT_XATTR              = (0x0080)
    EXTRACT_SECURE_SYMLINKS    = (0x0100)
    EXTRACT_SECURE_NODOTDOT    = (0x0200)
    EXTRACT_NO_AUTODIR         = (0x0400)
    EXTRACT_NO_OVERWRITE_NEWER = (0x0800)
    EXTRACT_SPARSE             = (0x1000)

    def self.read_open_filename file_name, command = nil, &block
        Reader.open_filename file_name, command, &block
    end

    def self.read_open_memory string, command = nil, &block
        Reader.open_memory string, command, &block
    end

    def self.write_open_filename file_name, compression, format, &block
        Writer.open_filename file_name, compression, format, &block
    end

    def self.write_open_memory string, compression, format, &block
        Writer.open_memory string, compression, format, &block
    end

    def self.version_number
        C::archive_version_number
    end

    def self.version_string
        C::archive_version_string
    end

    class Error < StandardError
        def initialize(archive)
            super C::archive_error_string(archive)
        end
    end

    class BaseArchive

        def initialize alloc, free
            @archive = alloc.call
            @archive_free = [nil]
            raise Error, @archive unless @archive

            @archive_free[0] = free
            ObjectSpace.define_finalizer( self, BaseArchive.finalizer(@archive, @archive_free) )
        end

        def self.finalizer archive, archive_free
            Proc.new do |*args|
                archive_free[0].call(archive) if archive_free[0]
            end
        end

        def close
            # TODO: do we need synchronization here?
            if @archive
                raise Error, @archive if @archive_free[0].call(@archive) != C::OK
            end
        ensure
            @archive = nil
            @archive_free[0] = nil
        end

        def archive
            raise Error, "No archive open" unless @archive
            @archive
        end
        protected :archive

        def error_string
            C::archive_error_string(@archive)
        end

        def errno
            C::archive_errno(@archive)
        end
    end

end
