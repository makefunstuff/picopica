const std = @import("std");
const testing = std.testing;
const mem = std.mem;
const tga = @import("tga.zig");
const TgaFooter = tga.TgaFooter;
const TgaHeader = tga.TgaHeader;
const TgaImageSpec = tga.TgaImageSpec;
const TgaImageData = tga.TgaImageData;

const Pixel = struct {
    b: u8,
    g: u8,
    r: u8,
};
fn make_rect(width: u16, height: u16) ![]Pixel {
    const rect = try std.heap.page_allocator.alloc(Pixel, width * height);
    for (rect) |*pixel| {
        pixel.* = Pixel{ .b = 0xFF, .g = 0x00, .r = 0x00 }; // Red in BGR format
    }
    return rect;
}

pub fn main() !void {
    const image_width: u16 = 200;
    const image_height: u16 = 200;
    const rectangle = try make_rect(image_width, image_height);
    defer std.heap.page_allocator.free(rectangle);

    const image_spec = TgaImageSpec{
        .x_origin = 0,
        .y_origin = 0,
        .image_width = image_width,
        .image_height = image_height,
        .pixel_depth = 24,
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
