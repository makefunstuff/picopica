const std = @import("std");
const testing = std.testing;

pub const TgaImageType = enum(u8) {
    COLOR_MAPPED = 1,
    TRUE_COLOR = 2,
    GRAYSCALE = 3,
    RLE_COLOR_MAPPED = 9,
    RLE_TRUE_COLOR = 10,
    RLE_GRAYSCALE = 11,
};

pub const TgaImageSpec = packed struct {
    x_origin: u16,
    y_origin: u16,
    image_width: u16,
    image_height: u16,
    pixel_depth: u8,
    image_descriptor: u8,
};

pub const TgaColorMapSpec = packed struct {
    first_entry_idx: u16,
    color_map_len: u16,
    color_map_entry_size: u8,
};

pub const TgaHeader = packed struct {
    idlength: u8,
    colormap_type: u8,
    image_type: TgaImageType,
    color_map_spec: TgaColorMapSpec,
    image_spec: TgaImageSpec,
};

pub const TgaImageData = struct {
    image_id: ?[]u8,
    color_map_data: ?[]u8,
    image_data: []u8, // width * height pixels
};

pub const TgaFooter = struct {
    extension_area_offset: u32,
    developer_area_offset: u32,
    signature: [16]u8,
    reserved_char: u8,
    zero_terminator: u8,

    pub fn init() TgaFooter {
        return .{
            .extension_area_offset = 0,
            .developer_area_offset = 0,
            .signature = "TRUEVISION-XFILE".*,
            .reserved_char = '.',
            .zero_terminator = 0,
        };
    }
};

// TODO: maybe not needed at all
const TgaExtensionArea = struct {};
const TgaDeveloperAreay = struct {};

test "tga header should be exactly 18 bytes in total" {
    try testing.expect(@sizeOf(TgaHeader) == 18);
}
