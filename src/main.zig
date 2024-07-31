const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const tga = @import("tga.zig");
const TgaFooter = tga.TgaFooter;
const TgaHeader = tga.TgaHeader;
const TgaImageSpec = tga.TgaImageSpec;
const TgaImageData = tga.TgaImageData;
const Allocator = mem.Allocator;

fn make_rect(width: u32, height: u32, bits_per_pixel: u32, allocator: Allocator) ![]u8 {
    const bytes_per_pixel = bits_per_pixel / 8;
    const total_pixels = width * height;
    const total_bytes = total_pixels * bytes_per_pixel;

    const rect = try allocator.alloc(u8, total_bytes);

    const red_color: u32 = 0x0000FF; // Red in BGR format, stored as 0x00BBGGRR

    var pixel_index: usize = 0;
    while (pixel_index < total_bytes) : (pixel_index += bytes_per_pixel) {
        rect[pixel_index] = @as(u8, red_color & 0xFF); // Blue channel
        rect[pixel_index + 1] = @as(u8, (red_color >> 8) & 0xFF); // Green channel
        rect[pixel_index + 2] = @as(u8, (red_color >> 16) & 0xFF); // Red channel
    }

    return rect;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const image_width: u16 = 200;
    const image_height: u16 = 200;
    const bits_per_pixel: u8 = 24;
    const rectangle = try make_rect(@as(u32, image_width), @as(u32, image_height), @as(u32, bits_per_pixel), allocator);

    defer std.heap.page_allocator.free(rectangle);

    const image_spec = TgaImageSpec{
        .x_origin = 0,
        .y_origin = 0,
        .image_width = image_width,
        .image_height = image_height,
        .pixel_depth = bits_per_pixel,
        .image_descriptor = 0,
    };

    const tga_header = TgaHeader{
        .idlength = 0,
        .colormap_type = 0,
        .image_type = .TRUE_COLOR,
        .color_map_spec = .{ .first_entry_idx = 0, .color_map_len = 0, .color_map_entry_size = 0 },
        .image_spec = image_spec,
    };

    const tga_image_data = TgaImageData{
        .image_id = null,
        .color_map_data = null,
        .image_data = std.mem.sliceAsBytes(rectangle),
    };

    const tga_footer = TgaFooter.init();

    const tga_file = try std.fs.cwd().createFile("rect.tga", .{
        .read = true,
    });
    defer tga_file.close();

    const writer = tga_file.writer();
    try writer.writeAll(std.mem.asBytes(&tga_header));
    try writer.writeAll(tga_image_data.image_data);
    try writer.writeAll(std.mem.asBytes(&tga_footer));
}
