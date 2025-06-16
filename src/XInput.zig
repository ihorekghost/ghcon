const std = @import("std");
const windows = @import("std").os.windows;
const ghwin = @import("ghwin");

const Input = @import("Input.zig");

pub const DeviceFilter = enum(u32) {
    @"0" = 0,
    @"1" = 1,
    @"2" = 2,
    @"3" = 3,
    any = 255,
};

const GamepadButtons = struct {
    pub const Type = u16;

    pub const dpad_up: Type = 0x0001;
    pub const dpad_down: Type = 0x0002;
    pub const dpad_left: Type = 0x0004;
    pub const dpad_right: Type = 0x0008;
    pub const start: Type = 0x0010;
    pub const back: Type = 0x0020;
    pub const left_stick: Type = 0x0040;
    pub const right_stick: Type = 0x0080;
    pub const left_shoulder: Type = 0x0100;
    pub const right_shoulder: Type = 0x0200;
    pub const a: Type = 0x1000;
    pub const b: Type = 0x2000;
    pub const x: Type = 0x4000;
    pub const y: Type = 0x8000;
};

const KeystrokeFlags = struct {
    pub const Type = u16;

    pub const key_down: Type = 0x0001;
    pub const key_up: Type = 0x0002;
    pub const repeat: Type = 0x0004;
};

const State = extern struct {
    packet: u32,
    gamepad: Gamepad,
};

const Keystroke = extern struct {
    pub const Flags = KeystrokeFlags;

    virtual_key: ghwin.VirtualKey16,
    unicode: u16,
    flags: Flags.Type,
    device_index: u8,
    HID_code: u8,
};

const Vibration = extern struct {
    ///`std.math.minInt(u16)` - `std.math.maxInt(u16)`
    left_motor_speed: u16,
    ///`std.math.minInt(u16)` - `std.math.maxInt(u16)`
    right_motor_speed: u16,
};

const Gamepad = extern struct {
    pub const Buttons = GamepadButtons;

    buttons: Buttons.Type,

    ///0-255
    left_trigger: u8,
    ///0-255
    right_trigger: u8,

    ///`std.math.minInt(i16)` - `std.math.maxInt(i16)`
    left_stick_x: i16,
    ///`std.math.minInt(i16)` - `std.math.maxInt(i16)`
    left_stick_y: i16,
    ///`std.math.minInt(i16)` - `std.math.maxInt(i16)`
    right_stick_x: i16,
    ///`std.math.minInt(i16)` - `std.math.maxInt(i16)`
    right_stick_y: i16,
};

const raw = struct {
    pub extern "Xinput9_1_0" fn XInputGetState(device_index: u32, state: *State) callconv(.winapi) ghwin.Win32Error_u32;
    pub extern "Xinput9_1_0" fn XInputEnable(enabled: ghwin.IntBool) callconv(.winapi) void;
    pub extern "Xinput9_1_0" fn XInputGetKeystroke(device_filter: DeviceFilter, reserved: u32, keystroke: *Keystroke) ghwin.Win32Error_u32;
};

fn getState(device_index: u32) ghwin.Error!State {
    var state: State = std.mem.zeroes(State);

    const err = raw.XInputGetState(device_index, &state);

    if (err != .SUCCESS) {
        return ghwin.win32ErrorToError(err);
    }

    return state;
}

fn getKeystroke(device_filter: DeviceFilter) ghwin.Error!Keystroke {
    var keystroke: Keystroke = std.mem.zeroes(Keystroke);

    const err = raw.XInputGetKeystroke(device_filter, 0, &keystroke);

    if (err != .SUCCESS) {
        return ghwin.win32ErrorToError(err);
    }

    return keystroke;
}

const enable = raw.XInputEnable;

pub const Event = struct {
    device_index: u2,
    key: Input.Gamepad.Key,
    pressed: bool,
};

pub const PopEventError = error{ GotInvalidDeviceIndex, GotNonGamepadKey } || ghwin.Error;

pub fn popEvent(filter: DeviceFilter, gamepads: ?*[4]Input.Gamepad) PopEventError!Event {
    const keystroke: Keystroke = try getKeystroke(filter);

    const device_index: u2 = if (keystroke.device_index < 4) @intCast(keystroke.device_index) else return PopEventError.GotInvalidDeviceIndex;
    const key: Input.Gamepad.Key = Input.Gamepad.Key.fromVirtual(keystroke.virtual_key) orelse return PopEventError.GotNonGamepadKey;
    const pressed: bool = (keystroke.flags & KeystrokeFlags.key_down) != 0;

    if (gamepads) |pads| {
        const key_state = pads[@intCast(device_index)].getKeyState(key);

        key_state.pressed = pressed;
        key_state.times_pressed += @intFromBool(pressed);
        key_state.times_released += @intFromBool(!pressed);
    }

    return Event{
        .device_index = device_index,
        .key = key,
        .pressed = pressed,
    };
}
