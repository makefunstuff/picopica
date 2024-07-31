const std = @import("std");
const tga = @import("tga.zig");
const drawing = @import("drawing.zig");

const testing = std.testing;
const mem = std.mem;
const TgaFooter = tga.TgaFooter;
const TgaHeader = tga.TgaHeader;
const TgaImageSpec = tga.TgaImageSpec;
const TgaImageData = tga.TgaImageData;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const image_width: u16 = 200;
    const image_height: u16 = 200;
    const bits_per_pixel: u8 = 24;
    const peach_color: u32 = 0x98A1FF;

    const bytes_per_pixel = @as(u32, @intCast(bits_per_pixel)) / 8;
    const total_pixels = image_width * image_height;
    const total_bytes = total_pixels * bytes_per_pixel;

    var canvas = try allocator.alloc(u8, total_bytes);
    try drawing.fill_canvas(&canvas, peach_color);

    defer std.heap.page_allocator.free(canvas);

    // TODO: make it less verbose
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
        .image_data = std.mem.sliceAsBytes(canvas),
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
