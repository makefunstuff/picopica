const std = @import("std");
const testing = std.testing;

const TgaColorMapType = enum(u8) {
    COLOR_MAPPED = 1,
    TRUE_COLOR = 2,
    GRAYSCALE = 3,
    RLE_COLOR_MAPPED = 9,
    RLE_TRUE_COLOR = 10,
    RLE_GRAYSCALE = 11,
};

const TgaImageSpec = struct {
    x_origin: [2]u8,
    y_origin: [2]u8,
    image_width: [2]u8,
    image_height: [2]u8,
    pixel_depth: u8,
    image_descriptor: u8,
};

const TgaColorMapSpec = struct {
    first_entry_idx: [2]u8,
    color_map_len: [2]u8,
    color_map_entry_size: u8,
};

const TgaHeader = struct {
    idlength: u8,
    colourmap_type: TgaColorMapType,
    image_type: u8,
    color_map_spec: TgaColorMapSpec,
    image_spec: TgaImageSpec,
};

const TgaImageData = struct {
    image_id: [*]u8,
    color_map_data: ?[*]u8,
    image_data: ?[*]u8, // width * height pixels
};

// TODO: maybe not needed at all
const TgaExtensionArea = struct {};
const TgaDeveloperAreay = struct {};

const Pixel = u24;

pub fn main() !void {}

test "tga header should be exacly of 18 bytes in total" {
    try testing.expect(@sizeOf(TgaHeader) == 18);
}
