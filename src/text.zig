const std = @import("std");

const ghmath = @import("ghmath");

const Canvas = @import("canvas.zig").Canvas;
const Rgb8 = @import("rgb8.zig").Rgb8;

/// Pass this to `ghgrid.GridEx(Glyph, --> ... <--)`.
pub const WriterContext = struct {
    canvas: *const Canvas,
    pos: ghmath.Vec2i32,
    current_color: Rgb8,
    start_x: i32,
};

pub const WriteError = error{};

fn write(context_any: *const anyopaque, bytes: []const u8) anyerror!usize {
    const context: *WriterContext = @constCast(@ptrCast(@alignCast(context_any)));

    for (bytes) |b| {
        if (b == '\n') {
            context.pos[1] += 1;
            context.pos[0] = context.start_x;
        }

        _ = context.canvas.draw(context.pos, .initColor(b, context.current_color));

        if (b != '\n') context.pos[0] += 1;
    }

    return bytes.len;
}

/// Ignores `\n` characters. Returns position of the next character after the written text.
pub fn drawTextRaw(canvas: *const Canvas, pos: ghmath.Vec2i32, text: []const u8, color: Rgb8) ghmath.Vec2i32 {
    if (pos[1] < 0 or pos[1] >= canvas.size[1] or pos[0] >= canvas.size[0]) return pos;

    const start_x = pos[0];
    const end_x: i32 = pos[0] + @as(i32, @intCast(text.len));

    const clamped_start_x = @max(0, start_x);
    const clamped_end_x = @min(@as(i32, @intCast(canvas.size[0])), end_x);

    const left_offset: u32 = @intCast(clamped_start_x - pos[0]);
    const right_offset: u32 = @intCast(end_x - clamped_end_x);

    if (left_offset > text.len) return pos;

    var i: usize = left_offset;

    while (i < (text.len - right_offset)) : (i += 1) {
        _ = canvas.drawUnsafe(ghmath.Vec2i32{ @as(i32, @intCast(i)) + pos[0], pos[1] }, .initColor(text[i], color));
    }

    return ghmath.Vec2i32{ @as(i32, @intCast(i)) + pos[0] + 1, pos[1] };
}

/// Takes `\n` characters into account.
pub fn drawText(canvas: *const Canvas, pos: ghmath.Vec2i32, text: []const u8, color: Rgb8) *const Canvas {
    var y: i32 = pos[1];

    var split_iter = std.mem.splitScalar(u8, text, '\n');
    while (split_iter.next()) |line| {
        _ = drawTextRaw(canvas, .{ pos[0], y }, line, color);

        y += 1;
    }

    return canvas;
}

/// `std.io.Writer` style print.
pub fn print(canvas: *const Canvas, text_pos: ghmath.Vec2i32, comptime fmt: []const u8, args: anytype) *const Canvas {
    var context: WriterContext = .{
        .canvas = canvas,
        .pos = text_pos,
        .start_x = text_pos[0],
        .current_color = .{ 255, 255, 255 },
    };

    std.fmt.format(std.io.AnyWriter{ .context = @alignCast(@ptrCast(&context)), .writeFn = write }, fmt, args) catch {};

    return canvas;
}
