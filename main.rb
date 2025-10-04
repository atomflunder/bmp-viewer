require_relative "./src/bmp"

puts "Type the file path for the .bmp file"
file_name = gets.chomp

bmp = Bmp.from_file_path(file_name)
r = bmp.to_r
g = bmp.to_g
b = bmp.to_b
gr = bmp.grayscale

r.print_bmp
g.print_bmp
b.print_bmp

bmp.print_bmp
gr.print_bmp

recon = Bmp::from_rgb_bitmaps(r, g, b)

recon.print_bmp

rm = recon.mirror

rm.print_bmp