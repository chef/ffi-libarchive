module Archive

    # TODO: Remove this forward-declaration
    class BaseArchive
    end

    class Writer < BaseArchive

        private_class_method :new

        def self.open_filename file_name, compression, format
            if block_given?
                writer = open_filename file_name, compression, format
                yield writer
                writer.close
            else
                new :file_name => file_name, :compression => compression, :format => format
            end
        end

        def self.open_memory string, compression, format
            if block_given?
                writer = open_memory string, compression, format
                yield writer
                writer.close
            else
                if compression.kind_of? String
                    command = compression
                    compression = -1
                else
                    command = nil
                end
                new :memory => string, :compression => compression, :format => format
            end
        end

        def initialize params = {}
            super C::method(:archive_write_new), C::method(:archive_write_finish)

            raise Error, @archive if C::archive_write_set_compression(archive, params[:compression]) != C::OK

            raise Error, @archive if C::archive_write_set_format(archive, params[:format]) != C::OK

            if params[:file_name]
                raise Error, @archive if C::archive_write_open_filename(archive, params[:file_name]) != C::OK
            elsif params[:memory]
                str = params[:memory]
                @data = FFI::MemoryPointer.new :pointer
                raise Error, @archive if C::archive_write_open(archive, @data, OpenCallback, CloseCallback, WriteCallback) != C::OK
            end
        rescue => e
            puts "AAA #{e}"
            close
            raise
        end

        OpenCallback = Proc.new do |archive, client|
            puts "open"
            if C::archive_write_get_bytes_in_last_block(archive) == -1
                C::archive_write_set_bytes_in_last_block(archive, 1)
            end

            C::OK
        end

        CloseCallback = Proc.new do |archive, client|
            puts "close"
            C::OK
        end

        WriteCallback = Proc.new do |archive, client, buffer, length|
            puts "write"
            buffer.concat client.get_string(0,length)
            length
        end

        def new_entry
            entry = Entry.new
            if block_given?
                result = yield entry
                entry.close
                result
            else
                entry
            end
        end

        def write_data *args
            if block_given?
                raise ArgumentError, "wrong number of argument (#{args.size} for 0)" if args.size > 0

                ar = archive
                len = 0
                while true do
                    str = yield
                    if ((n = C::archive_write_data(ar, str, str.size)) < 1)
                        return len
                    end
                    len += n
                end
            else
                raise ArgumentError, "wrong number of argument (#{args.size}) for 1)" if args.size != 1
                str = args[0]
                C::archive_write_data(archive, str, str.size)
            end
        end

        def write_header entry
            raise Error, @archive if C::archive_write_header(archive, entry.entry) != C::OK
        end

    end

end
