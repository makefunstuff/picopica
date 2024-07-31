const std = @import("std");
const tga = @import("tga.zig");
const drawing = @import("drawing.zig");

const testing = std.testing;
const mem = std.mem;
const TgaFooter = tga.TgaFooter;
const TgaHeader = tga.TgaHeader;
const TgaImageSpec = tga.TgaImageSpec;
const TgaImageData = tga.TgaImageData;
const Allocator = mem.Allocator;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const image_width: u16 = 200;
    const image_height: u16 = 200;
    const bits_per_pixel: u8 = 24;
    const peach_color: u32 = 0x98A1FF;
    const rectangle = try drawing.fill_canvas(@as(u32, image_width), @as(u32, image_height), @as(u32, bits_per_pixel), peach_color, allocator);

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
