const ghmath = @import("ghmath");

const Viewport = @import("Viewport.zig");

normalized: ghmath.Vec2f32,

pub const zero: @This() = @This(){ .normalized = .{ 0, 0 } };

pub fn init(normalized_mouse_pos: ghmath.Vec2f32) @This() {
    return @This(){ .normalized = normalized_mouse_pos };
}

pub fn pixels(mouse_pos: @This(), viewport: Viewport) ghmath.Vec2f32 {
    var client_area_size = viewport.size;

    client_area_size[0] += @intCast(viewport.pos[0] * 2);
    client_area_size[1] += @intCast(viewport.pos[1] * 2);

    const mouse_pos_client_pixels: ghmath.Vec2i32 = @intFromFloat(@as(ghmath.Vec2f32, @floatFromInt(client_area_size)) * mouse_pos.normalized);

    return @floatFromInt(mouse_pos_client_pixels - viewport.pos);
}

pub fn glyphs(mouse_pos: @This(), viewport: Viewport, size_glyphs: ghmath.Vec2u32) ghmath.Vec2f32 {
    const viewport_relative_pos_pixels: ghmath.Vec2f32 = mouse_pos.pixels(viewport);

    const glyph_size_viewport = viewport.glyphSize(size_glyphs);

    if (glyph_size_viewport[0] == 0 or glyph_size_viewport[1] == 0) return .{ 0, 0 };

    return viewport_relative_pos_pixels / glyph_size_viewport;
}
