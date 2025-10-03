module Utils
    def self.print_rgb_block(rgb)
        unless rgb[0] && rgb[1] && rgb[2]
            return
        end

        red   = rgb[0].to_i(16)
        green = rgb[1].to_i(16)
        blue  = rgb[2].to_i(16)

        print "\033[48;2;#{red};#{green};#{blue}m  \033[0m"
    end

    def self.bytes_to_i32(hex_array, offset)
        bytes = hex_array[offset, 4]
        [bytes.join].pack("H*").unpack1("V")
    end

    def self.bytes_to_i16(hex_array, offset)
        bytes = hex_array[offset, 2]
        [bytes.join].pack("H*").unpack1("v")
    end
end