const std = @import("std");

const ghmath = @import("ghmath");

pub const cascadia_code_json = @embedFile("cascadia_code_json");
pub const glyph_outer_padding = 4;

/// Array of glyphs positions, each position is specified in texture coordinates.
glyphs_positions: [256][2]f32 = [1][2]f32{[2]f32{ 1, 1 }} ** 256,
/// Size of one glyph in the font atlas, in texture coordinates.
glyph_size: [2]f32,

pixel_distance_range: f32,

const JsonGlyph = struct {
    ///ASCII code
    unicode: u8,

    ///In pixels
    atlasBounds: struct {
        left: f32,
        top: f32,
    } = .{ .left = 0, .top = 0 },
};

const Json = struct {
    atlas: struct {
        size: f32,
        width: u32,
        height: u32,
        distanceRange: f32,
        grid: struct {
            cellWidth: f32,
            cellHeight: f32,
        },
    },
    glyphs: []JsonGlyph,
};

pub const FromJsonError = (std.mem.Allocator.Error || std.json.ParseError(std.json.Scanner) || error{
    AtlasWidthIsZero,
    AtlasHeightIsZero,
    CellWidthTooSmall,
    CellHeightTooSmall,
});
pub fn fromJson(allocator: std.mem.Allocator, bytes: []const u8) FromJsonError!@This() {
    const parsed = try std.json.parseFromSlice(Json, allocator, bytes, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();

    const json: *const Json = &parsed.value;

    if (json.atlas.width == 0) return FromJsonError.AtlasWidthIsZero;
    if (json.atlas.height == 0) return FromJsonError.AtlasHeightIsZero;
    if (json.atlas.grid.cellWidth < (glyph_outer_padding * 2)) return FromJsonError.CellWidthTooSmall;
    if (json.atlas.grid.cellHeight < (glyph_outer_padding * 2)) return FromJsonError.CellHeightTooSmall;

    var font_atlas_metrics: @This() = @This(){
        .pixel_distance_range = json.atlas.distanceRange,
        .glyph_size = ghmath.Vec2f32{
            json.atlas.grid.cellWidth - glyph_outer_padding * 2,
            json.atlas.grid.cellHeight - glyph_outer_padding * 2,
        } / ghmath.Vec2f32{ @floatFromInt(json.atlas.width), @floatFromInt(json.atlas.height) },
    };

    //Extract glyphs position from parsed JSON
    for (0..json.glyphs.len) |i| {
        if (json.glyphs[i].unicode == ' ') continue;

        font_atlas_metrics.glyphs_positions[json.glyphs[i].unicode] = [2]f32{
            (json.glyphs[i].atlasBounds.left) / @as(f32, @floatFromInt(json.atlas.width)),
            (json.glyphs[i].atlasBounds.top) / @as(f32, @floatFromInt(json.atlas.height)),
        };
    }

    return font_atlas_metrics;
}
