const ghcon = @import("root.zig");

pub const Glyph = packed struct(u32) {
    pub const alpha_char = 1;
    pub const filled_char = 2;

    pub const alpha = @This(){
        .char = alpha_char,
    };

    pub fn isAlpha(glyph: @This()) bool {
        return glyph.char == alpha_char;
    }

    color: ghcon.Rgb8 = .{ 0, 0, 0 },
    char: u8 = alpha_char,

    pub fn init(char: u8, r: u8, g: u8, b: u8) @This() {
        return @This(){ .char = char, .color = .{ r, g, b } };
    }

    pub fn initColor(char: u8, color: ghcon.Rgb8) @This() {
        return @This(){ .char = char, .color = color };
    }

    pub fn withColor(glyph: @This(), color: ghcon.Rgb8) @This() {
        return @This(){ .char = glyph.char, .color = color };
    }

    pub fn withChar(glyph: @This(), char: u8) @This() {
        return @This(){ .char = char, .color = glyph.color };
    }

    pub fn filled(r: u8, g: u8, b: u8) @This() {
        return @This(){ .char = filled_char, .color = .{ r, g, b } };
    }

    pub fn filledColor(color: ghcon.Rgb8) @This() {
        return @This(){ .char = filled_char, .color = color };
    }
};
