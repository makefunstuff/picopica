pub fn fill_canvas(pixels: *[]u8, color: u32) !void {
    const bytes_per_pixel = 3;
    var pixel_index: usize = 0;
    while (pixel_index < pixels.len) : (pixel_index += bytes_per_pixel) {
        pixels.*[pixel_index] = @as(u8, @intCast(color & 0xFF));
        pixels.*[pixel_index + 1] = @as(u8, @intCast((color >> 8) & 0xFF));
        pixels.*[pixel_index + 2] = @as(u8, @intCast((color >> 16) & 0xFF));

        if (bytes_per_pixel > 3) {
            pixels[pixel_index + 3] = 0; // Alpha channel or padding
        }
    }
}

// TODO
// pub fn fill_rect([*]u8 pixels, width: u32, height: u32, x: u32, y: u32)
