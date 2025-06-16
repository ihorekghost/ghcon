//!Contains state of keyboard keys (down|up, ?just_pressed, ?just_released), mouse buttons (down|up, ?just_pressed, ?just_released), gamepad buttons (down|up, ?just_pressed, ?just_released) and sticks (axes).
//!Has to be manually updated by chosen input backend. Set `Window.input` to make window responsible for updating the input state. RawInput and XInput are not supported yet.

const std = @import("std");

const ghmath = @import("ghmath");
const ghwin = @import("ghwin");

pub const Gamepads = @import("Gamepads.zig");
pub const Keyboard = @import("Keyboard.zig");
pub const Mouse = @import("Mouse.zig");
const MousePos = @import("MousePos.zig");
const Viewport = @import("Viewport.zig");
const WindowEvent = @import("WindowEvent.zig");

keyboard: ?*Keyboard = null,
mouse: ?*Mouse = null,
gamepads: ?*Gamepads = null,

pub fn processKeyboardEvent(input: *const @This(), event: KeyboardEvent) void {
    if (input.keyboard) |keyboard| keyboard.processEvent(event);
}

pub fn processMouseEvent(input: *const @This(), event: MouseEvent) void {
    if (input.mouse) |mouse| mouse.processEvent(event);
}

pub fn processWindowEvent(input: *const @This(), data: WindowEvent.Data) void {
    switch (data) {
        .keyboard_key => |keyboard_key| input.processKeyboardEvent(keyboard_key),
        .mouse_button => |mouse_button| input.processMouseEvent(mouse_button),
        else => {},
    }
}

pub fn clean(input: *const @This()) void {
    if (input.keyboard) |keyboard| keyboard.clean();
    if (input.mouse) |mouse| mouse.clean();
    //if (input.gamepads) |gamepads| gamepads.clean();
}

pub fn pressed(input: *const @This(), key: Key) bool {
    if (key.isKeyboard() and input.keyboard != null) return input.keyboard.?.pressed(@as(Keyboard.Key, @enumFromInt(@intFromEnum(key))));
    if (key.isMouse() and input.mouse != null) return input.mouse.?.pressed(@as(Mouse.Button, @enumFromInt(@intFromEnum(key))));

    return false;
}

pub fn timesPressed(input: *const @This(), key: Key) u8 {
    if (key.isKeyboard() and input.keyboard != null) return input.keyboard.?.timesPressed(@as(Keyboard.Key, @enumFromInt(@intFromEnum(key))));
    if (key.isMouse() and input.mouse != null) return input.mouse.?.timesPressed(@as(Mouse.Button, @enumFromInt(@intFromEnum(key))));

    return 0;
}

pub fn timesReleased(input: *const @This(), key: Key) u8 {
    if (key.isKeyboard() and input.keyboard != null) return input.keyboard.?.timesReleased(@as(Keyboard.Key, @enumFromInt(@intFromEnum(key))));
    if (key.isMouse() and input.mouse != null) return input.mouse.?.timesReleased(@as(Mouse.Button, @enumFromInt(@intFromEnum(key))));

    return 0;
}

pub fn justPressed(input: *const @This(), key: Key) bool {
    if (key.isKeyboard() and input.keyboard != null) return input.keyboard.?.justPressed(@as(Keyboard.Key, @enumFromInt(@intFromEnum(key))));
    if (key.isMouse() and input.mouse != null) return input.mouse.?.justPressed(@as(Mouse.Button, @enumFromInt(@intFromEnum(key))));

    return false;
}

pub fn justReleased(input: *const @This(), key: Key) bool {
    if (key.isKeyboard() and input.keyboard != null) return input.keyboard.?.justReleased(@as(Keyboard.Key, @enumFromInt(@intFromEnum(key))));
    if (key.isMouse() and input.mouse != null) return input.mouse.?.justReleased(@as(Mouse.Button, @enumFromInt(@intFromEnum(key))));

    return false;
}

pub fn strength(input: *const @This(), key: Key) u1 {
    return @intFromBool(input.pressed(key));
}

pub fn getAxis(input: *const @This(), negative: Key, positive: Key) i2 {
    return @as(i2, input.strength(positive)) - @as(i2, input.strength(negative));
}

pub fn getVector(
    input: *const @This(),
    negative_x: Key,
    positive_x: Key,
    negative_y: Key,
    positive_y: Key,
) @Vector(2, i2) {
    return @Vector(2, i2){ input.getAxis(negative_x, positive_x), input.getAxis(negative_y, positive_y) };
}

pub fn getVectorNormalized(
    input: *const @This(),
    negative_x: Key,
    positive_x: Key,
    negative_y: Key,
    positive_y: Key,
) ghmath.Vec2f32 {
    return ghmath.normalizeOrZero(@as(ghmath.Vec2f32, @floatFromInt(input.getVector(negative_x, positive_x, negative_y, positive_y))));
}

///Represents a keyboard key, mouse button, gamepad button, gamepad stick press or movement.
pub const Key = enum(u16) {
    //  Mouse buttons
    left_mouse_button = 0x01,
    right_mouse_button = 0x02,
    middle_mouse_button = 0x04,
    x1_mouse_button = 0x05,
    x2_mouse_button = 0x06,

    //  Keyboard keys
    cancel = 0x03,
    back = 0x08,
    tab = 0x09,
    clear = 0x0c,
    @"return" = 0x0d,
    shift = 0x10,
    control = 0x11,
    menu = 0x12,
    pause = 0x13,
    capital = 0x14,
    kana = 0x15,
    ime_on = 0x16,
    junja = 0x17,
    final = 0x18,
    hanja = 0x19,
    ime_off = 0x1a,
    escape = 0x1b,
    convert = 0x1c,
    non_convert = 0x1d,
    accept = 0x1e,
    mode_change = 0x1f,
    space = 0x20,
    prior = 0x21,
    next = 0x22,
    end = 0x23,
    home = 0x24,
    left = 0x25,
    up = 0x26,
    right = 0x27,
    down = 0x28,
    select = 0x29,
    print = 0x2a,
    execute = 0x2b,
    snapshot = 0x2c,
    insert = 0x2d,
    delete = 0x2e,
    help = 0x2f,
    @"0" = 0x30,
    @"1" = 0x31,
    @"2" = 0x32,
    @"3" = 0x33,
    @"4" = 0x34,
    @"5" = 0x35,
    @"6" = 0x36,
    @"7" = 0x37,
    @"8" = 0x38,
    @"9" = 0x39,
    a = 0x41,
    b = 0x42,
    c = 0x43,
    d = 0x44,
    e = 0x45,
    f = 0x46,
    g = 0x47,
    h = 0x48,
    i = 0x49,
    j = 0x4a,
    k = 0x4b,
    l = 0x4c,
    m = 0x4d,
    n = 0x4e,
    o = 0x4f,
    p = 0x50,
    q = 0x51,
    r = 0x52,
    s = 0x53,
    t = 0x54,
    u = 0x55,
    v = 0x56,
    w = 0x57,
    x = 0x58,
    y = 0x59,
    z = 0x5a,
    left_win = 0x5b,
    right_win = 0x5c,
    apps = 0x5d,
    sleep = 0x5f,
    numpad0 = 0x60,
    numpad1 = 0x61,
    numpad2 = 0x62,
    numpad3 = 0x63,
    numpad4 = 0x64,
    numpad5 = 0x65,
    numpad6 = 0x66,
    numpad7 = 0x67,
    numpad8 = 0x68,
    numpad9 = 0x69,
    multiply = 0x6a,
    add = 0x6b,
    separator = 0x6c,
    subtract = 0x6d,
    decimal = 0x6e,
    divide = 0x6f,
    f1 = 0x70,
    f2 = 0x71,
    f3 = 0x72,
    f4 = 0x73,
    f5 = 0x74,
    f6 = 0x75,
    f7 = 0x76,
    f8 = 0x77,
    f9 = 0x78,
    f10 = 0x79,
    f11 = 0x7a,
    f12 = 0x7b,
    f13 = 0x7c,
    f14 = 0x7d,
    f15 = 0x7e,
    f16 = 0x7f,
    f17 = 0x80,
    f18 = 0x81,
    f19 = 0x82,
    f20 = 0x83,
    f21 = 0x84,
    f22 = 0x85,
    f23 = 0x86,
    f24 = 0x87,
    num_lock = 0x90,
    scroll = 0x91,
    left_shift = 0xa0,
    right_shift = 0xa1,
    left_control = 0xa2,
    right_control = 0xa3,
    left_menu = 0xa4,
    right_menu = 0xa5,
    browser_back = 0xa6,
    browser_forward = 0xa7,
    browser_refresh = 0xa8,
    browser_stop = 0xa9,
    browser_search = 0xaa,
    browser_favourites = 0xab,
    browser_home = 0xac,
    volume_mute = 0xad,
    volume_down = 0xae,
    volume_up = 0xaf,
    media_next_track = 0xb0,
    media_prev_track = 0xb1,
    media_stop = 0xb2,
    media_play_pause = 0xb3,
    launch_mail = 0xb4,
    launch_media_select = 0xb5,
    launch_app1 = 0xb6,
    launch_app2 = 0xb7,
    oem_1 = 0xba,
    plus = 0xbb,
    comma = 0xbc,
    minus = 0xbd,
    period = 0xbe,
    oem_2 = 0xbf,
    oem_3 = 0xc0,
    oem_4 = 0xdb,
    oem_5 = 0xdc,
    oem_6 = 0xdd,
    oem_7 = 0xde,
    oem_8 = 0xdf,
    oem_102 = 0xe2,
    process_key = 0xe5,
    packet = 0xe7,
    attn = 0xf6,
    cr_sel = 0xf7,
    ex_sel = 0xf8,
    erase_eof = 0xf9,
    play = 0xfa,
    zoom = 0xfb,
    pa1 = 0xfd,
    oem_clear = 0xfe,

    //Gamepad buttons
    gamepad_a = 0x5800,
    gamepad_b = 0x5801,
    gamepad_x = 0x5802,
    gamepad_y = 0x5803,
    right_shoulder = 0x5804,
    left_shoulder = 0x5805,
    left_trigger = 0x5806,
    right_trigger = 0x5807,
    gamepad_start = 0x5814,
    gamepad_back = 0x5815,

    //Gampead dpad
    dpad_up = 0x5810,
    dpad_down = 0x5811,
    dpad_left = 0x5812,
    dpad_right = 0x5813,

    //Gamepad stick presses
    left_stick_press = 0x5816,
    right_stick_press = 0x5817,

    //Gamepad stick movements
    left_stick_up = 0x5820,
    left_stick_down = 0x5821,
    left_stick_right = 0x5822,
    left_stick_left = 0x5823,
    left_stick_up_left = 0x5824,
    left_stick_up_right = 0x5825,
    left_stick_down_right = 0x5826,
    left_stick_down_left = 0x5827,
    right_stick_up = 0x5830,
    right_stick_down = 0x5831,
    right_stick_right = 0x5832,
    right_stick_left = 0x5833,
    right_stick_up_left = 0x5834,
    right_stick_up_right = 0x5835,
    right_stick_down_right = 0x5836,
    right_stick_down_left = 0x5837,

    pub fn isGamepad(key: @This()) bool {
        return switch (key) {
            .gamepad_a,
            .gamepad_b,
            .gamepad_x,
            .gamepad_y,
            .right_shoulder,
            .left_shoulder,
            .left_trigger,
            .right_trigger,
            .gamepad_start,
            .gamepad_back,
            .dpad_up,
            .dpad_down,
            .dpad_left,
            .dpad_right,
            .left_stick_press,
            .right_stick_press,
            .left_stick_up,
            .left_stick_down,
            .left_stick_right,
            .left_stick_left,
            .left_stick_up_left,
            .left_stick_up_right,
            .left_stick_down_right,
            .left_stick_down_left,
            .right_stick_up,
            .right_stick_down,
            .right_stick_right,
            .right_stick_left,
            .right_stick_up_left,
            .right_stick_up_right,
            .right_stick_down_right,
            .right_stick_down_left,
            => true,
            else => false,
        };
    }

    pub fn isKeyboard(key: @This()) bool {
        return switch (key) {
            .gamepad_a,
            .gamepad_b,
            .gamepad_x,
            .gamepad_y,
            .right_shoulder,
            .left_shoulder,
            .left_trigger,
            .right_trigger,
            .gamepad_start,
            .gamepad_back,
            .dpad_up,
            .dpad_down,
            .dpad_left,
            .dpad_right,
            .left_stick_press,
            .right_stick_press,
            .left_stick_up,
            .left_stick_down,
            .left_stick_right,
            .left_stick_left,
            .left_stick_up_left,
            .left_stick_up_right,
            .left_stick_down_right,
            .left_stick_down_left,
            .right_stick_up,
            .right_stick_down,
            .right_stick_right,
            .right_stick_left,
            .right_stick_up_left,
            .right_stick_up_right,
            .right_stick_down_right,
            .right_stick_down_left,
            .left_mouse_button,
            .right_mouse_button,
            .middle_mouse_button,
            .x1_mouse_button,
            .x2_mouse_button,
            => false,
            else => true,
        };
    }

    pub fn isMouse(key: @This()) bool {
        return switch (key) {
            .left_mouse_button, .right_mouse_button, .middle_mouse_button, .x1_mouse_button, .x2_mouse_button => true,
            else => false,
        };
    }

    pub fn fromVirtual(VirtualKeyChild: type, virtual_key: ghwin.VirtualKey(VirtualKeyChild)) ?@This() {
        if (virtual_key == ._) return null;

        return @enumFromInt(@intFromEnum(virtual_key));
    }

    pub fn fromKeyboard(keyboard_key: Keyboard.Key) @This() {
        return @enumFromInt(@intFromEnum(keyboard_key));
    }
    pub fn fromGamepad(gamepad_button: Gamepads.Key) @This() {
        return @enumFromInt(@intFromEnum(gamepad_button));
    }
    pub fn fromMouse(mouse_button: Mouse.Button) @This() {
        return @enumFromInt(@intFromEnum(mouse_button));
    }
};

pub const KeyState = struct {
    pressed: bool,
    times_pressed: u8,
    times_released: u8,

    pub const init = @This(){
        .pressed = false,
        .times_pressed = 0,
        .times_released = 0,
    };
};

pub const KeyboardEvent = struct {
    key: Keyboard.Key,
    pressed: bool,
};

pub const MouseButtonAction = enum {
    press,
    release,
    double_click,
};

pub const MouseEvent = struct {
    pub const Action = MouseButtonAction;

    button: Mouse.Button,
    action: Action,
    /// In normalized space (0.0 - 1.0)
    pos: MousePos,
};

pub const GamepadEvent = struct {
    device_index: u2,
    key: Gamepads.Key,
};
