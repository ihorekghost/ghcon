const std = @import("std");

const ghmath = @import("ghmath");

pos: @Vector(2, i32),
size: @Vector(2, u32),

pub const zeroes = @This(){
    .pos = .{ 0, 0 },
    .size = .{ 0, 0 },
};

pub fn init(x: i32, y: i32, width: u32, height: u32) @This() {
    return @This(){
        .pos = .{ x, y },
        .size = .{ width, height },
    };
}

pub fn vecs(pos: @Vector(2, f32), size: @Vector(2, f32)) @This() {
    return @This(){
        .pos = pos,
        .size = size,
    };
}

pub fn aspectRatio(viewport: *const @This()) f32 {
    const width: f32 = @floatFromInt(viewport.size[0]);
    const height: f32 = @floatFromInt(viewport.size[1]);

    return width / height;
}

pub fn aspectRatioScale(viewport: *const @This(), target_aspect_ratio: f32) @This() {
    const current_aspect_ratio: f32 = viewport.aspectRatio();

    var new_viewport: @This() = viewport.*;

    if (current_aspect_ratio > target_aspect_ratio) {
        // Too wide — reduce width
        const new_width: f32 = @as(f32, @floatFromInt(viewport.size[1])) * target_aspect_ratio;
        const delta: f32 = @as(f32, @floatFromInt(viewport.size[0])) - new_width;
        new_viewport.pos[0] += @intFromFloat(delta / 2.0); // center it horizontally
        new_viewport.size[0] = @intFromFloat(new_width);
    } else if (current_aspect_ratio < target_aspect_ratio) {
        // Too tall — reduce height
        const new_height: f32 = @as(f32, @floatFromInt(viewport.size[0])) / target_aspect_ratio;
        const delta: f32 = @as(f32, @floatFromInt(viewport.size[1])) - new_height;
        new_viewport.pos[1] += @intFromFloat(delta / 2.0); // center it vertically
        new_viewport.size[1] = @intFromFloat(new_height);
    }

    return new_viewport;
}

/// Calculate size of one glyph in the viewport.
pub fn glyphSize(viewport: *const @This(), size_glyphs: ghmath.Vec2u32) ghmath.Vec2f32 {
    const viewport_size_f32: ghmath.Vec2f32 = @floatFromInt(viewport.size);
    const size_glyphs_f32: ghmath.Vec2f32 = @floatFromInt(size_glyphs);

    return viewport_size_f32 / size_glyphs_f32;
}
