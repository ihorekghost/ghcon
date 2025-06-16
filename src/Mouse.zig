const ghwin = @import("ghwin");

const Input = @import("Input.zig");

pub fn pressed(mouse: *@This(), button: Button) bool {
    return mouse.constButtonState(button).pressed;
}

pub fn timesPressed(mouse: *const @This(), button: Button) u8 {
    return mouse.constButtonState(button).times_pressed;
}

pub fn timesReleased(mouse: *const @This(), button: Button) u8 {
    return mouse.constButtonState(button).times_released;
}

pub fn justPressed(mouse: *const @This(), button: Button) bool {
    return mouse.timesPressed(button) > 0;
}

pub fn justReleased(mouse: *const @This(), button: Button) bool {
    return mouse.timesReleased(button) > 0;
}

pub fn processEvent(mouse: *@This(), event: Input.MouseEvent) void {
    mouse.buttonState(event.button).pressed = event.action != .release;
    if (event.action != .release) {
        mouse.buttonState(event.button).times_pressed += 1;
    } else {
        mouse.buttonState(event.button).times_released += 1;
    }
}

///Set buttons' `times_pressed` and `times_released` fields to `0`. This method is intended to be called every frame after data from `Mouse` is processed.
pub fn clean(mouse: *@This()) void {
    for (0..mouse.buttons.len) |i| {
        mouse.buttons[i].times_pressed = 0;
        mouse.buttons[i].times_released = 0;
    }
}

pub fn buttonState(mouse: *@This(), button: Button) *Input.KeyState {
    return switch (button) {
        .left => &mouse.buttons[0],
        .right => &mouse.buttons[1],
        .middle => &mouse.buttons[2],
        .x1 => &mouse.buttons[3],
        .x2 => &mouse.buttons[4],
    };
}

pub fn constButtonState(mouse: *const @This(), button: Button) *const Input.KeyState {
    return switch (button) {
        .left => &mouse.buttons[0],
        .right => &mouse.buttons[1],
        .middle => &mouse.buttons[2],
        .x1 => &mouse.buttons[3],
        .x2 => &mouse.buttons[4],
    };
}

pub const Button = enum(u3) {
    //              Every field value maps to a corresponding field of `ghwin.VirtualKey(...)`:
    left = 1, //        - VirtualKey(...).left_mouse_button
    right = 2, //       - VirtualKey(...).right_mouse_button
    middle = 4, //      - VirtualKey(...).middle_mouse_button
    x1 = 5, //          - VirtualKey(...).x1_mouse_button
    x2 = 6, //          - VirtualKey(...).x2_mouse_button

    ///Convert a key to the corresponding mouse button. Returns `null` if key does not map to a mouse button.
    pub fn fromKey(key: Input.Key) ?@This() {
        return switch (key) {
            .left_mouse_button, .right_mouse_button, .middle_mouse_button, .x1_mouse_button, .x2_mouse_button => @enumFromInt(@intFromEnum(key)),
            else => null,
        };
    }

    pub fn fromVirtual(comptime VirtualKeyChild: type, virtual_key: ghwin.VirtualKey(VirtualKeyChild)) ?@This() {
        if (!virtual_key.isMouse()) return null;

        return @enumFromInt(@intFromEnum(virtual_key));
    }

    pub fn fromXButtonIndex(index: ghwin.MessageWParam.XButton.Index) ?@This() {
        return switch (index) {
            .@"1" => .x1,
            .@"2" => .x2,
            _ => null,
        };
    }

    ///Returns a lowercase string representation of a mouse button.
    pub fn name(button: @This()) [:0]const u8 {
        return @tagName(button);
    }
};

buttons: [5]Input.KeyState = [1]Input.KeyState{Input.KeyState.init} ** 5,
