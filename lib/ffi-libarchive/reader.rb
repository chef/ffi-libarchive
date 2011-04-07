module Archive

    class Reader

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
            @archive_free = [false]
            @archive = C::archive_read_new
            raise Error(@archive) unless @archive

            if params[:command]
                cmd = params[:command]
                raise Error, @archive if C::archive_read_support_compression_program(@archive, cmd) != C::OK
            else
                raise Error, @archive if C::archive_read_support_compression_all(@archive) != C::OK
            end

            raise Error, @archive if C::archive_read_support_format_all(@archive) != C::OK

            if params[:file_name]
                raise Error, @archive if C::archive_read_open_filename(@archive, params[:file_name], 1024) != C::OK
            elsif params[:memory]
                str = params[:memory]
                raise Error, @archive if C::archive_read_open_memory(@archive, str, str.size) != C::OK
            end

            ObjectSpace.define_finalizer( self, Reader.finalizer(@archive, @archive_free) )
        rescue
            close
            raise
        end

        def self.finalizer archive, archive_free
            Proc.new do |*args|
                unless archive_free[0]
                    C::archive_read_finish(archive)
                end
            end
        end

        def close
            # TODO: do we need synchronization here?
            @archive_free[0] = true
            if @archive
                raise Error, @archive if C::archive_read_finish(@archive) != C::OK
            end
        ensure
            @archive = nil
        end

        def extract entry, flags = 0
            raise Error, "No archive open" unless @archive
            raise ArgumentError, "Expected Archive::Entry as first argument" unless entry.kind_of? Entry
            raise ArgumentError, "Expected Integer as second argument" unless entry.kind_of? Integer

            flags &= EXTRACT_FLAGS
            raise Error, @archive if C::archive_read_extract(@archive, entry, flags) != C::OK
        end

        def header_position
            raise Error, "No archive open" unless @archive
            raise Error, @archive if C::archive_read_header_position @archive
        end

        def next_header
            raise Error, "No archive open" unless @archive

            entry_ptr = FFI::MemoryPointer.new(:pointer)
            case C::archive_read_next_header(@archive, entry_ptr)
            when C::OK
                Entry.from_pointer entry_ptr.get_pointer(0)
            when C::EOF
                @eof = true
            else
                raise Error, @archive
            end
        end

        def read_data size = C::DATA_BUFFER_SIZE
            raise Error, "No archive open" unless @archive

            if block_given?
                buf = FFI::MemoryPointer.new :uchar, size
                while (n = C::archive_read_data(@archive, buffer, C::DATA_BUFFER_SIZE)) > 0
                    yield buf.read_string(n)
                end
            else
                data = ""
                buf = FFI::MemoryPointer.new :uchar, size
                while (n = C::archive_read_data(@archive, buffer, C::DATA_BUFFER_SIZE)) > 0
                    data.concat buf.read_string(n)
                end
                data
            end
        end

        def save_data file_name
            raise Error, "No archive open" unless @archive

            IO.sysopen(file_name, "wb") do |fd|
                raise Error, @archive if C::archive_read_data_into_fd(@archive, fd) != C::OK
            end
        end

    end

end
