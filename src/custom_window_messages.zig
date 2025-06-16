const ghwin = @import("ghwin");

pub const close = ghwin.MessageKind.custom(1);
pub const destroy = ghwin.MessageKind.custom(2);
pub const set_focus = ghwin.MessageKind.custom(3);
pub const kill_focus = ghwin.MessageKind.custom(4);
pub const move = ghwin.MessageKind.custom(5);
pub const size = ghwin.MessageKind.custom(6);

pub fn fromMessage(message: ghwin.MessageKind) ghwin.MessageKind {
    return switch (message) {
        .window_close => close,
        .window_destroy => destroy,
        .window_set_focus => set_focus,
        .window_kill_focus => kill_focus,
        .window_move => move,
        .window_size => size,
        else => .null,
    };
}

pub fn isCustom(message: ghwin.MessageKind) bool {
    return switch (message) {
        close, destroy, set_focus, kill_focus, move, size => true,
        else => false,
    };
}
