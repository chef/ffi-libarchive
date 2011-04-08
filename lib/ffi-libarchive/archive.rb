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
