const ghmath = @import("ghmath");
const ghwin = @import("ghwin");

const Input = @import("Input.zig");

pub fn pressed(keyboard: *const @This(), key: Key) bool {
    return keyboard.keys[@intFromEnum(key)].pressed;
}

pub fn timesPressed(keyboard: *const @This(), key: Key) u8 {
    return keyboard.keys[@intFromEnum(key)].times_pressed;
}

pub fn timesReleased(keyboard: *const @This(), key: Key) u8 {
    return keyboard.keys[@intFromEnum(key)].times_released;
}

pub fn justPressed(keyboard: *const @This(), key: Key) bool {
    return keyboard.timesPressed(key) > 0;
}

pub fn justReleased(keyboard: *const @This(), key: Key) bool {
    return keyboard.timesReleased(key) > 0;
}

pub fn strength(keyboard: *const @This(), key: Key) u1 {
    return @intFromBool(keyboard.pressed(key));
}

pub fn getAxis(keyboard: *const @This(), negative: Key, positive: Key) i2 {
    return @as(i2, keyboard.strength(positive)) - @as(i2, keyboard.strength(negative));
}

pub fn getVector(
    keyboard: *const @This(),
    negative_x: Key,
    positive_x: Key,
    negative_y: Key,
    positive_y: Key,
) @Vector(2, i2) {
    return @Vector(2, i2){ keyboard.getAxis(negative_x, positive_x), keyboard.getAxis(negative_y, positive_y) };
}

pub fn getVectorNormalized(
    keyboard: *const @This(),
    negative_x: Key,
    positive_x: Key,
    negative_y: Key,
    positive_y: Key,
) @Vector(2, f32) {
    return ghmath.normalizeOrZero(@as(@Vector(2, f32), @floatFromInt(keyboard.getVector(negative_x, positive_x, negative_y, positive_y))));
}

pub fn processEvent(keyboard: *@This(), event: Input.KeyboardEvent) void {
    keyboard.keys[@as(usize, @intFromEnum(event.key))].pressed = event.pressed;
    if (event.pressed) {
        keyboard.keys[@as(usize, @intFromEnum(event.key))].times_pressed += 1;
    } else {
        keyboard.keys[@as(usize, @intFromEnum(event.key))].times_released += 1;
    }
}

///Set keys' `times_pressed` and `times_released` fields to `0`. This method is intended to be called every frame after data from `Keyboard` is processed.
pub fn clean(keyboard: *@This()) void {
    for (0..keyboard.keys.len) |i| {
        keyboard.keys[i].times_pressed = 0;
        keyboard.keys[i].times_released = 0;
    }
}

///Represents a keyboard key. Has all the same values as `Key` (`ghwin.VirtualKey8`), except those which map to mouse / gamepad buttons.
pub const Key = enum(u8) {
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

    pub fn fromKey(key: Input.Key) ?@This() {
        if (key.isKeyboard()) return @enumFromInt(@intFromEnum(key)) else return null;
    }

    pub fn fromVirtual(comptime VirtualKeyChild: type, virtual_key: ghwin.VirtualKey(VirtualKeyChild)) ?@This() {
        if (!virtual_key.isKeyboard()) return null;

        return @enumFromInt(@intFromEnum(virtual_key));
    }
};

keys: [256]Input.KeyState = [1]Input.KeyState{Input.KeyState.init} ** 256,
