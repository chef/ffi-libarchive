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

            compression = params[:compression]
            case compression
            when Symbol
                compression = Archive::const_get("COMPRESSION_#{compression.to_s.upcase}".intern)
            end

            format = params[:format]
            case format
            when Symbol
                format = Archive::const_get("FORMAT_#{format.to_s.upcase}".intern)
            end

            raise Error, @archive if C::archive_write_set_compression(archive, compression) != C::OK

            raise Error, @archive if C::archive_write_set_format(archive, format) != C::OK

            if params[:file_name]
                raise Error, @archive if C::archive_write_open_filename(archive, params[:file_name]) != C::OK
            elsif params[:memory]
                str = params[:memory]
                @data = lambda{ |ar, client, buffer, length|
                    str.concat buffer.get_bytes(0,length)
                    length
                }
                raise Error, @archive if C::archive_write_open(archive, nil,
                                                               method(:open_callback),
                                                               @data,
                                                               nil) != C::OK
            end
        rescue => e
            close
            raise
        end

        def open_callback archive, client
            if C::archive_write_get_bytes_in_last_block(archive) == -1
                C::archive_write_set_bytes_in_last_block(archive, 1)
            end
            C::OK
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
