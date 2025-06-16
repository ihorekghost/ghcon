const std = @import("std");
pub const utf16le = std.unicode.utf8ToUtf16LeStringLiteral;

/// Exposed `ghdbg` dependency module. You can use it for asserts with custom failure messages.
pub const ghdbg = @import("ghdbg");
/// Exposed `ghgrid` dependency module. See `Canvas`.
pub const ghgrid = @import("ghgrid");
/// Exposed `ghmath` dependency module. You can use it for vector math.
pub const ghmath = @import("ghmath");
/// Exposed `ghwin` dependency module. You can use it if you want low-level access to Win32 API.
pub const ghwin = @import("ghwin");
/// Exposed `zigimg` dependency module. Will get in handy when initializing a font atlas.
pub const zigimg = @import("zigimg");

pub const canvas = @import("canvas.zig");
pub const Canvas = canvas.Canvas;
pub const colors = @import("colors.zig");
pub const FontAtlas = @import("FontAtlas.zig");
pub const FontAtlasMetrics = @import("FontAtlasMetrics.zig");
pub const Glyph = @import("glyph.zig").Glyph;
pub const Input = @import("Input.zig");
pub const Keyboard = @import("Keyboard.zig");
pub const LayerStack = @import("LayerStack.zig");
pub const Mouse = @import("Mouse.zig");
pub const MousePos = @import("MousePos.zig");
pub const Renderer = @import("Renderer.zig");
pub const RenderTarget = @import("RenderTarget.zig");
pub const Rgb8 = @import("rgb8.zig").Rgb8;
pub const Rgb8Fmt = @import("Rgb8Fmt.zig");
pub const Viewport = @import("Viewport.zig");
pub const Window = @import("Window.zig");
pub const Vsync = Window.Vsync;
pub const WindowClass = @import("WindowClass.zig");
pub const Cursor = WindowClass.Cursor;
pub const WindowEvent = @import("WindowEvent.zig");

//pub const Texture = @import("Texture.zig");
//pub const StagingTexture = @import("StagingTexture.zig");

pub fn rgb8Fmt(rgb8: Rgb8) Rgb8Fmt {
    return Rgb8Fmt.init(rgb8);
}
