const std = @import("std");

const ghcon = @import("root.zig");

color: ghcon.Rgb8,

pub fn init(rgb8: ghcon.Rgb8) @This() {
    return .{ .color = rgb8 };
}

pub fn format(rgb8_fmt: @This(), comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    const context: *ghcon.Canvas.WriterContext = @constCast(@ptrCast(@alignCast(writer.context)));

    _ = fmt;
    _ = options;

    context.current_color = rgb8_fmt.color;
}
