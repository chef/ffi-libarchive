module Archive

    class Writer

        private_class_method :new

        def self.open_filename file_name, compression, format
            if block_given?
                writer = open_filename file_name, compression, format
                yield writer
                writer.close
            else
                new
            end
        end

        def self.open_memory string, compression, format
            if block_given?
                writer = open_memory string, compression, format
                yield writer
                writer.close
            else
                new
            end
        end

        def initialize
        end

        def close
        end

        def new_entry
        end

        def write_data
        end

        def write_header
        end

    end

end
