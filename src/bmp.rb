require_relative "./utils"

class Bmp
    @width
    @height
    @image_bytes

    def initialize(width, height, image_bytes)
        @width = width
        @height = height
        @image_bytes = image_bytes
    end

    def width
        @width
    end

    def height
        @height
    end

    def image_bytes
        @image_bytes
    end

    def self.from_file_path(file_path)
        unless file_path.end_with?(".bmp")
            throw "Not a valid BMP file!"
        end

        data = File.binread(file_path)
        raw_bytes = data.bytes.map { |b| "%02X" % b }

        # BMP headers are at least 54 bytes long and start with 'B' 'M'
        unless raw_bytes.length() > 55 && raw_bytes[0] == "42" && raw_bytes[1] == "4D"
            throw "Invalid BMP file!"
        end

        unless Utils::bytes_to_i16(raw_bytes, 28) == 24
            throw "Only 24 Bit BMP files are supported!"
        end

        unless Utils::bytes_to_i32(raw_bytes, 30) == 0
            throw "Only uncompressed BMP files are supported!"
        end

        width  = Utils::bytes_to_i32(raw_bytes, 18)
        height = Utils::bytes_to_i32(raw_bytes, 22)

        pixel_data_offset = Utils::bytes_to_i32(raw_bytes, 10)

        row_length = width * 3
        if row_length % 4 != 0
            row_length += 4 - row_length % 4
        end

        image_bytes = []

        for y in 0..height - 1 do
            row = []

            for x in 0..width - 1 do
                rgb = []

                location = (x * 3) + (y * row_length) + pixel_data_offset
                rgb.push(raw_bytes[location + 2], raw_bytes[location + 1], raw_bytes[location])

                row << rgb
            end

            image_bytes << row
        end

        image_bytes.reverse!

        return self.new(width, height, image_bytes)
    end

    def self.from_rgb_bitmaps(bmp_r, bmp_g, bmp_b)
        unless [bmp_r.width, bmp_g.width, bmp_b.width].uniq.size <= 1
            throw "Invalid heights for the bitmaps!"
        end

        unless [bmp_r.height, bmp_g.height, bmp_b.height].uniq.size <= 1
            throw "Invalid heights for the bitmaps!"
        end

        width = bmp_r.width
        height = bmp_r.height
        image_bytes = []

        for y in 0..height - 1 do
            row = []
            for x in 0..width - 1 do
                row << [bmp_r.image_bytes[y][x][0], bmp_g.image_bytes[y][x][1], bmp_b.image_bytes[y][x][2]]
            end
            image_bytes << row
        end

        Bmp.new(width, height, image_bytes)
    end

    def print_bmp
        for y in 0..@height - 1 do
            for x in 0..@width - 1 do
                Utils::print_rgb_block(@image_bytes[y][x])
            end
            puts
        end
    end

    def mirror
        image_bytes = @image_bytes
        image_bytes.each { |r| r.reverse! }

        Bmp.new(@width, @height, image_bytes)
    end

    def rotate_90
        image_bytes = @image_bytes.transpose

        b = Bmp.new(@height, @width, image_bytes)
        
        b.mirror
    end

    def grayscale
        image_bytes = []

        for y in 0..@height - 1 do
            row = []
            for x in 0..@width - 1 do
                red_i = @image_bytes[y][x][0].to_i(16)
                green_i = @image_bytes[y][x][1].to_i(16)
                blue_i = @image_bytes[y][x][2].to_i(16)

                gray = (red_i * 0.2125 + green_i * 0.7154 + blue_i * 0.0721).round.to_s(16)

                row << [gray, gray, gray]
            end
            image_bytes << row
        end

        Bmp.new(@width, @height, image_bytes)
    end

    def to_r
        image_bytes = []

        for y in 0..@height - 1 do
            row = []
            for x in 0..@width - 1 do
                row << [@image_bytes[y][x][0], "00", "00"]
            end
            image_bytes << row
        end

        Bmp.new(@width, @height, image_bytes)
    end

    def to_g
        image_bytes = []

        for y in 0..@height - 1 do
            row = []
            for x in 0..@width - 1 do
                row << ["00", @image_bytes[y][x][1], "00"]
            end
            image_bytes << row
        end

        Bmp.new(@width, @height, image_bytes)
    end

    def to_b
        image_bytes = []

        for y in 0..@height - 1 do
            row = []
            for x in 0..@width - 1 do
                row << ["00", "00", @image_bytes[y][x][2]]
            end
            image_bytes << row
        end

        Bmp.new(@width, @height, image_bytes)
    end
end

