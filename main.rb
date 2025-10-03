require_relative "./src/bmp"

puts "Type the file path for the .bmp file"
file_name = gets.chomp

b = Bmp.new(file_name)
b.rotate_90
b.mirror_bmp
b.to_grayscale
b.print_bmp