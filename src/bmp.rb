require_relative "./utils"

class Bmp
    @file_name
    @width
    @height
    @file_size
    @raw_bytes
    @image_bytes

    def initialize(file_path = "./input/rgb24.bmp")
        unless file_path.end_with?(".bmp")
            throw "Not a valid BMP file!"
        end

        @file_name = file_path

        data = File.binread(file_path)
        @raw_bytes = data.bytes.map { |b| "%02X" % b }

        # BMP headers are at least 54 bytes long and start with 'B' 'M'
        unless @raw_bytes.length() > 55 && @raw_bytes[0] == "42" && @raw_bytes[1] == "4D"
            throw "Invalid BMP file!"
        end

        unless Utils::bytes_to_i16(@raw_bytes, 28) == 24
            throw "Only 24 Bit BMP files are supported!"
        end

        unless Utils::bytes_to_i32(@raw_bytes, 30) == 0
            throw "Only uncompressed BMP files are supported!"
        end

        @width  = Utils::bytes_to_i32(@raw_bytes, 18)
        @height = Utils::bytes_to_i32(@raw_bytes, 22)

        pixel_data_offset = Utils::bytes_to_i32(@raw_bytes, 10)

        row_length = @width * 3
        if row_length % 4 != 0
            row_length += 4 - row_length % 4
        end

        @image_bytes = []

        for y in 0..@height - 1 do
            row = []

            for x in 0..@width - 1 do
                rgb = []

                location = (x * 3) + (y * row_length) + pixel_data_offset
                rgb.push(@raw_bytes[location], @raw_bytes[location + 1], @raw_bytes[location + 2])

                row << rgb
            end

            @image_bytes << row
        end

        @image_bytes.reverse!
    end

    def print_bmp
        for y in 0..@height - 1 do
            for x in 0..@width - 1 do
                Utils::print_rgb_block(@image_bytes[y][x])
            end
            puts
        end
    end

    def mirror_bmp
        @image_bytes.each { |r| r.reverse! }
    end

    def rotate_90
        old_width = @width
        @width = @height
        @height = old_width

        @image_bytes = @image_bytes.transpose
        mirror_bmp
    end

    def to_grayscale
        for y in 0..@height - 1 do
            for x in 0..@width - 1 do
                red_i = @image_bytes[y][x][2].to_i(16)
                green_i = @image_bytes[y][x][1].to_i(16)
                blue_i = @image_bytes[y][x][0].to_i(16)

                gray = (red_i * 0.2125 + green_i * 0.7154 + blue_i * 0.0721).round.to_s(16)

                @image_bytes[y][x] = [gray, gray, gray]
            end
        end
    end
end

