const std = @import("std");
const utf16le = std.unicode.utf8ToUtf16LeStringLiteral;

const ghwin = @import("ghwin");
pub const InitError = ghwin.Error;
pub const DeinitError = ghwin.Error;
pub const Cursor = ghwin.CursorOrdinal;

const custom_messages = @import("custom_window_messages.zig");
const dx = @import("dx.zig");
const log = @import("log.zig");
const RenderTarget = @import("RenderTarget.zig");
const Viewport = @import("Viewport.zig");
const Window = @import("Window.zig");

name: [*:0]const u16,

pub const InitOptions = struct {
    name: [*:0]const u16,
    cursor: Cursor = .arrow,
    double_clicks_detection: bool = false,
};

pub fn init(options: *const InitOptions) InitError!@This() {
    const desc: ghwin.WindowClassExW = ghwin.WindowClassExW{
        .window_extra_bytes = 0,
        .styles = ghwin.window_class_styles.double_clicks * @as(c_uint, @intFromBool(options.double_clicks_detection)),
        .instance = ghwin.getCurrentModuleHandle(),
        .name = options.name,
        .procedure = procedure,
        .cursor = try ghwin.loadCursorW(null, .{ .ordinal = options.cursor }),
    };

    _ = try ghwin.registerClassExW(&desc);

    return @This(){ .name = options.name };
}

pub fn deinit(window_class: @This()) ghwin.Error!void {
    ghwin.unregisterClassW(.{ .name = window_class.name }, ghwin.getCurrentModuleHandle()) catch |err| {
        log.err(@src(), "Failed to deinitialize window class: {}.", .{err});
        return err;
    };
}

fn procedure(handle: ghwin.WindowHandle, message_kind: ghwin.MessageKind, wparam: ghwin.MessageWParam, lparam: ghwin.MessageLParam) callconv(.winapi) ghwin.WindowProcedureResult {
    const custom_message = custom_messages.fromMessage(message_kind);

    //Read pointer to a `Window` structure from window's memory.
    if (Window.fromHandle(handle)) |window| {
        if (custom_message != .null) ghwin.postMessageW(if (message_kind == .window_destroy) null else handle, custom_message, if (message_kind == .window_destroy) ghwin.MessageWParam{ .usize = @intFromPtr(window) } else wparam, lparam) catch |err| {
            log.err(@src(), "Failed to post custom message to window's message queue: {}", .{err});
        };

        sw: switch (message_kind) {
            .window_show => {
                window.visible = wparam.window_visibility.toBool();
            },

            .window_move => {
                window.pos = lparam.client_rect_pos.toVec();
            },

            .window_size => {
                // Update size field
                window.size = lparam.client_rect_size.toVec();

                // Update sizing kind field
                window.sizing_kind = switch (wparam.resizing_kind) {
                    .restored => .normal,
                    .minimized => .minimized,
                    .maximized => .maximized,
                    else => window.sizing_kind,
                };

                //Release old render target view
                _ = dx.release(window.render_target.view);

                //Resize swap chain buffers
                dx.resizeBuffers(window.swap_chain, 0) catch |err| {
                    log.err(@src(), "Failed to resize swap chain buffers: {}", .{err});
                    break :sw;
                };

                //Get the back buffer
                const back_buffer: *dx.ID3D11Texture2D = dx.getBuffer(window.swap_chain, 0, dx.ID3D11Texture2D) catch |err| {
                    log.err(@src(), "Failed to get back buffer: {}", .{err});
                    break :sw;
                };
                defer _ = dx.release(back_buffer);

                //Create render target view with new size
                window.render_target.view = dx.createRenderTargetView(window.renderer.device, @ptrCast(back_buffer)) catch |err| {
                    log.err(@src(), "Failed to create render target view: {}", .{err});
                    break :sw;
                };
            },

            .window_xbutton_down, .window_xbutton_up, .window_xbutton_double_click => return .true,
            else => {},
        }
    }

    switch (message_kind) {
        .window_create, .window_close => return .success,
        else => {},
    }

    return ghwin.defWindowProcW(handle, message_kind, wparam, lparam);
}
