//! `.ghcon` scoped logging
const std = @import("std");
const SourceLocation = std.builtin.SourceLocation;

const log = @import("std").log.scoped(.ghcon);

/// Log an error message. This log level is intended to be used
/// when something has gone wrong. This might be recoverable or might
/// be followed by the program exiting.
pub fn err(
    comptime src: SourceLocation,
    comptime format: []const u8,
    args: anytype,
) void {
    log.err("{s}::{s}()::{}:{}:: " ++ format, .{ src.file, src.fn_name, src.line, src.column } ++ args);
}

/// Log a warning message. This log level is intended to be used if
/// it is uncertain whether something has gone wrong or not, but the
/// circumstances would be worth investigating.
pub fn warn(
    comptime src: SourceLocation,
    comptime format: []const u8,
    args: anytype,
) void {
    log.warn("{s}::{s}()::{}:{}:: " ++ format, .{ src.file, src.fn_name, src.line, src.column } ++ args);
}

/// Log an info message. This log level is intended to be used for
/// general messages about the state of the program.
pub fn info(
    comptime src: SourceLocation,
    comptime format: []const u8,
    args: anytype,
) void {
    log.info("{s}::{s}()::{}:{}:: " ++ format, .{ src.file, src.fn_name, src.line, src.column } ++ args);
}

/// Log a debug message. This log level is intended to be used for
/// messages which are only useful for debugging.
pub fn debug(
    comptime src: SourceLocation,
    comptime format: []const u8,
    args: anytype,
) void {
    log.debug("{s}::{s}()::{}:{}:: " ++ format, .{ src.file, src.fn_name, src.line, src.column } ++ args);
}
