module Archive

    class Reader

        def self.open_filename file_name, command = nil
            if block_given?
                reader = open_filename file_name, command
                yield reader
                reader.close
            else
                new
            end
        end

        def self.open_memory string, command = nil, &block
            if block_given?
                reader = open_memory string, command
                yield reader
                reader.close
            else
                new
            end
        end

        def initialize
        end

        def close
        end

        def extract
        end

        def header_position
        end

        def next_header
        end

        def read_data
        end

        def save_data
        end

    end

end
