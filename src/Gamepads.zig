const ghwin = @import("ghwin");

const Input = @import("Input.zig");

pub const Key = enum(u16) {
    //Gamepad buttons
    a = 0x5800,
    b = 0x5801,
    x = 0x5802,
    y = 0x5803,
    right_shoulder = 0x5804,
    left_shoulder = 0x5805,
    left_trigger = 0x5806,
    right_trigger = 0x5807,
    start = 0x5814,
    back = 0x5815,

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

    pub fn fromKey(key: Input.Key) @This() {
        if (key.isGamepad()) return @enumFromInt(@intFromEnum(key)) else return null;
    }

    pub fn fromVirtual(virtual_key: ghwin.VirtualKey16) ?@This() {
        if (!virtual_key.isGamepad()) return null;

        return @enumFromInt(@intFromEnum(virtual_key));
    }
};
