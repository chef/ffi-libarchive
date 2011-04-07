module Archive

    # TODO: Remove this forward-declaration
    class BaseArchive
    end

    class Reader < BaseArchive

        private_class_method :new

        def self.open_filename file_name, command = nil
            if block_given?
                reader = open_filename file_name, command
                yield reader
                reader.close
            else
                new :file_name => file_name, :command => command
            end
        end

        def self.open_memory string, command = nil, &block
            if block_given?
                reader = open_memory string, command
                yield reader
                reader.close
            else
                new :memory => string, :command => command
            end
        end

        def initialize params = {}
            super C::archive_read_new

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
                raise Error, @archive if C::archive_read_open_memory(archive, str, str.size) != C::OK
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
                Entry.from_pointer entry_ptr.get_pointer(0)
            when C::EOF
                @eof = true
            else
                raise Error, @archive
            end
        end

        def read_data size = C::DATA_BUFFER_SIZE
            if block_given?
                buffer = FFI::MemoryPointer.new :uchar, size
                while (n = C::archive_read_data(archive, buffer, C::DATA_BUFFER_SIZE)) > 0
                    case n
                    when C::FATAL, C::WARN, C::RETRY
                        raise Error, @archive
                    else
                        yield buffer.read_string(n)
                    end
                end
            else
                data = ""
                buffer = FFI::MemoryPointer.new :uchar, size
                while (n = C::archive_read_data(archive, buffer, C::DATA_BUFFER_SIZE)) > 0
                    case n
                    when C::FATAL, C::WARN, C::RETRY
                        raise Error, @archive
                    else
                        data.concat buffer.read_string(n)
                    end
                end
                data
            end
        end

        def save_data file_name
            IO.sysopen(file_name, "wb") do |fd|
                raise Error, @archive if C::archive_read_data_into_fd(archive, fd) != C::OK
            end
        end

    end

end
