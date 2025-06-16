const std = @import("std");
const assert = std.debug.assert;
const utf16le = std.unicode.utf8ToUtf16LeStringLiteral;

const ghmath = @import("ghmath");
const ghwin = @import("ghwin");
pub const default_metric: c_int = ghwin.use_default;

const Class = @import("WindowClass.zig");
const custom_messages = @import("custom_window_messages.zig");
const dx = @import("dx.zig");
pub const Event = @import("WindowEvent.zig");
const Input = @import("Input.zig");
const Keyboard = @import("Keyboard.zig");
const log = @import("log.zig");
const Mouse = @import("Mouse.zig");
const Renderer = @import("Renderer.zig");
const RenderTarget = @import("RenderTarget.zig");
const Viewport = @import("Viewport.zig");

handle: ghwin.WindowHandle,
swap_chain: *dx.IDXGISwapChain,
/// Can be accessed directly.
render_target: RenderTarget,

/// Window position, in pixels.
pos: ghmath.Vec2i16,
/// Window size, in pixels.
size: ghmath.Vec2u16,
/// Kind of window sizing: minimized, maximized or normal.
sizing_kind: SizingKind,
/// `true` if window is visible, otherwise `false`. Can be **read** directly. To set window visibility, use `Window.setVisibility(...)`.
visible: bool,

renderer: *const Renderer, //Renderer used to create and resize window's swap chain, create render target view.

pub const InitError = ghwin.Error || dx.Error || ghwin.CreateWindowExError;
pub const default_metrics: @Vector(2, c_int) = .{ default_metric, default_metric };

pub const SizingKind = enum {
    minimized,
    maximized,
    normal,

    pub fn toShowWindowAction(sizing_kind: @This()) ghwin.ShowWindowAction {
        return switch (sizing_kind) {
            .minimized => .minimize,
            .maximized => .maximize,
            .normal => .normal,
        };
    }
};

pub const InitOptions = struct {
    renderer: *const Renderer,
    class: Class,
    title: [*:0]const u16,
    pos: @Vector(2, c_int) = default_metrics,
    size: @Vector(2, c_int) = default_metrics,
    srgb: bool = false,
};

pub fn init(window: *@This(), options: *const InitOptions) InitError!void {
    const window_handle = try ghwin.createWindowExW(
        0,
        options.class.name,
        options.title,
        ghwin.window_styles.overlapped_window,
        options.pos[0],
        options.pos[1],
        options.size[0],
        options.size[1],
        null,
        null,
        try ghwin.getModuleHandleW(null),
        null,
    );
    errdefer ghwin.destroyWindow(window_handle) catch |err| log.err(@src(), "Failed to destroy window: {}", .{err});

    _ = try ghwin.setWindowLongPtrW(window_handle, .user_data, .{ .usize = @intFromPtr(window) });

    var swap_chain_desc = dx.DXGI_SWAP_CHAIN_DESC{
        .BufferDesc = .{
            .Width = 0,
            .Height = 0,
            .Format = if (options.srgb) dx.DXGI_FORMAT_R8G8B8A8_UNORM_SRGB else dx.DXGI_FORMAT_R8G8B8A8_UNORM,
            .Scaling = dx.DXGI_MODE_SCALING_UNSPECIFIED,
            .RefreshRate = .{
                .Denominator = 0,
                .Numerator = 0,
            },
            .ScanlineOrdering = dx.DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED,
        },
        .SampleDesc = .{ .Count = 1, .Quality = 0 },
        .Windowed = dx.TRUE,
        .OutputWindow = window_handle,
        .SwapEffect = dx.DXGI_SWAP_EFFECT_DISCARD,
        .Flags = 0,
        .BufferCount = 1,
        .BufferUsage = dx.DXGI_USAGE_RENDER_TARGET_OUTPUT,
    };

    const swap_chain: *dx.IDXGISwapChain = try dx.createSwapChain(options.renderer.dxgi_factory, options.renderer.device, &swap_chain_desc);
    errdefer _ = dx.release(swap_chain);

    const back_buffer: *dx.ID3D11Texture2D = try dx.getBuffer(swap_chain, 0, dx.ID3D11Texture2D);
    defer _ = dx.release(back_buffer);

    const render_target_view: *dx.ID3D11RenderTargetView = try dx.createRenderTargetView(options.renderer.device, @ptrCast(back_buffer));
    errdefer _ = dx.release(render_target_view);

    window.* = .{
        .handle = window_handle,
        .renderer = options.renderer,
        .swap_chain = swap_chain,
        .render_target = RenderTarget{ .view = render_target_view },
        .sizing_kind = .normal,
        .visible = false,
        .pos = .{ 0, 0 },
        .size = .{ 0, 0 },
    };
}

pub fn fromHandle(handle: ghwin.WindowHandle) ?*@This() {
    const long_ptr = ghwin.getWindowLongPtrW(handle, .user_data) catch return null; // If `ghwin.getWindowLongPtrW(...)` fails, null is returned here because the error code is not set anyway for some reason

    return @ptrFromInt(long_ptr.usize);
}

pub const Vsync = enum(u2) { none = 0, half = 2, full = 1 };

/// Swap front and back buffers.
pub fn swapBuffers(window: *const @This(), vsync: Vsync) dx.Error!void {
    if (window.size[0] == 0 or window.size[1] == 0) return;

    try dx.present(window.swap_chain, @intFromEnum(vsync));
}

/// Pop an event from any window event queue. To access the window to which the event belongs, use `Event.window` field.
pub fn popEvent() ?Event {
    while (ghwin.peekMessageW(null, .null, .null, .remove)) |message| {
        _ = ghwin.translateMessage(&message);
        if (!custom_messages.isCustom(message.kind)) _ = ghwin.dispatchMessageW(&message);

        if (Event.fromMessage(&message)) |event| return event;
    }

    return null;
}

pub fn deinit(window: *const @This()) ghwin.Error!void {
    ghwin.destroyWindow(window.handle) catch |err| {
        log.err(@src(), "Failed to deinitialize window: {}", .{err});
        return err;
    };
}

pub fn viewport(window: *const @This()) Viewport {
    return Viewport{ .pos = .{ 0, 0 }, .size = @intCast(window.size) };
}

pub fn eql(lhs: *const @This(), rhs: *const @This()) bool {
    return lhs.handle == rhs.handle;
}

/// Change window sizing kind: minimized, maximized or normal. **Window will automatically become visible.**
pub fn setSizingKind(window: *const @This(), sizing_kind: SizingKind) void {
    _ = ghwin.showWindow(window.handle, sizing_kind.toShowWindowAction());
}

pub fn minimize(window: *const @This()) void {
    window.setSizingKind(.minimized);
}

pub fn maximize(window: *const @This()) void {
    window.setSizingKind(.maximized);
}

pub fn normal(window: *const @This()) void {
    window.setSizingKind(.normal);
}

/// Show or hide the window.
pub fn setVisibility(window: *const @This(), visible: bool) void {
    _ = ghwin.showWindow(window.handle, if (visible) .show else .hide);
}

pub fn show(window: *const @This()) void {
    window.setVisibility(true);
}

pub fn hide(window: *const @This()) void {
    window.setVisibility(false);
}

pub fn moveOwnership(window: *const @This(), new_owner: *@This()) void {
    new_owner.* = window.*;

    _ = try ghwin.setWindowLongPtrW(window.handle, .user_data, .{ .usize = @intFromPtr(new_owner) });
}
