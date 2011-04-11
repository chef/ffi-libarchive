module Archive

    # TODO: Remove this forward-declaration
    class BaseArchive
    end

    class Reader < BaseArchive

        private_class_method :new

        def self.open_filename file_name, command = nil
            if block_given?
                reader = open_filename file_name, command
                begin
                    yield reader
                ensure
                    reader.close
                end
            else
                new :file_name => file_name, :command => command
            end
        end

        def self.open_memory string, command = nil
            if block_given?
                reader = open_memory string, command
                begin
                    yield reader
                ensure
                    reader.close
                end
            else
                new :memory => string, :command => command
            end
        end

        def initialize params = {}
            super C::method(:archive_read_new), C::method(:archive_read_finish)

            if params[:command]
                cmd = params[:command]
                raise Error, @archive if C::archive_read_support_compression_program(archive, cmd) != C::OK
            else
                raise Error, @archive if C::archive_read_support_compression_all(archive) != C::OK
            end

            raise Error, @archive if C::archive_read_support_format_all(archive) != C::OK

            if params[:file_name]
                raise Error, @archive if C::archive_read_open_filename(archive, params[:file_name], 1024) != C::OK
            elsif params[:memory]
                str = params[:memory]
                @data = FFI::MemoryPointer.new str.size
                @data.put_bytes 0, str
                raise Error, @archive if C::archive_read_open_memory(archive, @data, @data.size) != C::OK
            end
        rescue
            close
            raise
        end

        def extract entry, flags = 0
            raise ArgumentError, "Expected Archive::Entry as first argument" unless entry.kind_of? Entry
            raise ArgumentError, "Expected Integer as second argument" unless entry.kind_of? Integer

            flags &= EXTRACT_FLAGS
            raise Error, @archive if C::archive_read_extract(archive, entry, flags) != C::OK
        end

        def header_position
            raise Error, @archive if C::archive_read_header_position archive
        end

        def next_header
            entry_ptr = FFI::MemoryPointer.new(:pointer)
            case C::archive_read_next_header(archive, entry_ptr)
            when C::OK
                Entry.from_pointer entry_ptr.read_pointer
            when C::EOF
                @eof = true
                nil
            else
                raise Error, @archive
            end
        end

        def read_data size = C::DATA_BUFFER_SIZE, &block
            raise ArgumentError, "Buffer size must be > 0" unless size.kind_of?(Integer) and size > 0

            data = nil
            unless block
                data = ""
                block = data.method :concat
            end

            buffer = FFI::Buffer.alloc_out(size)
            len = 0
            while (n = C::archive_read_data(archive, buffer, size)) > 0
                case n
                when C::FATAL, C::WARN, C::RETRY
                    raise Error, @archive
                else
                    block.call buffer.get_bytes(0,n)
                end
                len += n
            end

            data || len
        end

        def save_data file_name
            IO.sysopen(file_name, "wb") do |fd|
                raise Error, @archive if C::archive_read_data_into_fd(archive, fd) != C::OK
            end
        end

    end

end
