const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn fill_canvas(width: u32, height: u32, bits_per_pixel: u32, color: u32, allocator: Allocator) ![]u8 {
    const bytes_per_pixel = bits_per_pixel / 8;
    const total_pixels = width * height;
    const total_bytes = total_pixels * bytes_per_pixel;

    const rect = try allocator.alloc(u8, total_bytes);

    var pixel_index: usize = 0;
    while (pixel_index < total_bytes) : (pixel_index += bytes_per_pixel) {
        rect[pixel_index] = @as(u8, @intCast(color & 0xFF));
        rect[pixel_index + 1] = @as(u8, @intCast((color >> 8) & 0xFF));
        rect[pixel_index + 2] = @as(u8, @intCast((color >> 16) & 0xFF));

        if (bytes_per_pixel > 3) {
            rect[pixel_index + 3] = 0; // Alpha channel or padding
        }
    }

    return rect;
}
