const ghmath = @import("ghmath");
const ghwin = @import("ghwin");

const custom_window_messages = @import("custom_window_messages.zig");
const Input = @import("Input.zig");
pub const KeyboardKey = Input.KeyboardEvent;
pub const MouseButton = Input.MouseEvent;
const Keyboard = @import("Keyboard.zig");
const Mouse = @import("Mouse.zig");
const MousePos = @import("MousePos.zig");
const Viewport = @import("Viewport.zig");
const Window = @import("Window.zig");

window: *Window,
data: Data,

pub const Kind = enum {
    /// Close ('X') menu button was pressed
    close,
    /// Window has been destroyed
    destroy,
    /// Keyboard key has been pressed
    keyboard_key,
    /// Mouse cursor has moved
    mouse_move,
    /// Mouse button has been pressed
    mouse_button,
    /// Window pos has changed.
    pos,
    /// Window size has changed.
    size,
    /// Window has got or lost focus
    focus,
};

pub fn fromMessage(message: *const ghwin.Message) ?@This() {
    const window = if (message.kind != custom_window_messages.destroy) (Window.fromHandle(message.window orelse return null) orelse return null) else @as(?*Window, @ptrFromInt(message.wparam.usize)) orelse return null;

    const data = Data.fromMessage(message, window.size) orelse return null;

    return @This(){ .data = data, .window = window };
}

// Appearance and/or window size has changed.
pub const Size = struct {
    /// New window size.
    size: ghmath.Vec2u16,

    /// Resizing kind: minimized, maximized or normal.
    kind: Window.SizingKind,
};

pub const Data = union(Kind) {
    /// Close ('X') menu button was pressed.
    close: void,
    /// Window has been destroyed.
    destroy: void,

    /// Keyboard key has been pressed.
    keyboard_key: KeyboardKey,
    /// Mouse cursor has moved.
    mouse_move: MousePos,
    /// Mouse button has been pressed.
    mouse_button: MouseButton,

    /// Window pos has changed. Holds new window **client area position**, in pixels.
    pos: ghmath.Vec2i16,
    /// Window size has changed. Holds new sizing kind and **size of window client area**, in pixels.
    size: Size,
    /// Window has got or lost focus.
    focus: bool,

    fn normalizedPos(pos_pixels: ghmath.Vec2i16, client_area_size: ghmath.Vec2u16) ghmath.Vec2f32 {
        return @as(ghmath.Vec2f32, @floatFromInt(pos_pixels)) / @as(ghmath.Vec2f32, @floatFromInt(client_area_size));
    }

    pub fn fromMessage(message: *const ghwin.Message, client_area_size: ghmath.Vec2u16) ?@This() {
        return switch (message.kind) {
            // Close and destroy (custom messages)
            custom_window_messages.close => .close,
            custom_window_messages.destroy => .destroy,

            // Keys
            .window_key_down => .{ .keyboard_key = .{ .key = Keyboard.Key.fromVirtual(u8, message.wparam.key) orelse return null, .pressed = true } },
            .window_key_up => .{ .keyboard_key = .{ .key = Keyboard.Key.fromVirtual(u8, message.wparam.key) orelse return null, .pressed = false } },

            // Mouse cursor movement
            .window_mouse_move => .{ .mouse_move = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) },

            // Mouse buttons (left, right, middle, x1, x2) down, up and double click
            .window_lbutton_down => .{ .mouse_button = .{ .button = .left, .action = .press, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_lbutton_up => .{ .mouse_button = .{ .button = .left, .action = .release, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_lbutton_double_click => .{ .mouse_button = .{ .button = .left, .action = .double_click, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_rbutton_down => .{ .mouse_button = .{ .button = .right, .action = .press, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_rbutton_up => .{ .mouse_button = .{ .button = .right, .action = .release, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_rbutton_double_click => .{ .mouse_button = .{ .button = .right, .action = .double_click, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_mbutton_down => .{ .mouse_button = .{ .button = .middle, .action = .press, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_mbutton_up => .{ .mouse_button = .{ .button = .middle, .action = .release, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_mbutton_double_click => .{ .mouse_button = .{ .button = .middle, .action = .double_click, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_xbutton_down => .{ .mouse_button = .{ .button = Mouse.Button.fromXButtonIndex(message.wparam.xbutton.index) orelse return null, .action = .press, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_xbutton_up => .{ .mouse_button = .{ .button = Mouse.Button.fromXButtonIndex(message.wparam.xbutton.index) orelse return null, .action = .release, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },
            .window_xbutton_double_click => .{ .mouse_button = .{ .button = Mouse.Button.fromXButtonIndex(message.wparam.xbutton.index) orelse return null, .action = .double_click, .pos = .init(normalizedPos(message.lparam.cursor_pos.toVec(), client_area_size)) } },

            // Focus
            custom_window_messages.set_focus => .{ .focus = true },
            custom_window_messages.kill_focus => .{ .focus = false },

            // Window position
            custom_window_messages.move => .{ .pos = message.lparam.client_rect_pos.toVec() },

            // Window size
            custom_window_messages.size => .{ .size = .{ .kind = switch (message.wparam.resizing_kind) {
                .restored => .normal,
                .minimized => .minimized,
                .maximized => .maximized,
                else => return null,
            }, .size = message.lparam.client_rect_size.toVec() } },

            else => null,
        };
    }
};
