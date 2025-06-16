const dx = @import("dx.zig");
const Renderer = @import("Renderer.zig");
const Viewport = @import("Viewport.zig");

view: *dx.ID3D11RenderTargetView,

///Color is normalized (0 to 1).
pub fn clear(render_target: @This(), renderer: *const Renderer, color: [4]f32) void {
    dx.clearRenderTargetView(renderer.device_context, render_target.view, color);
}

///Decrements `ID3D11RenderTargetView`'s reference count and returns its current value.
pub fn deinit(render_target: @This()) c_ulong {
    return dx.release(render_target.view);
}

pub fn eql(lhs: @This(), rhs: @This()) bool {
    return lhs.view == rhs.view;
}

pub fn size(render_target: @This()) @Vector(2, c_uint) {
    const texture: *dx.ID3D11Texture2D = @ptrCast(dx.getResource(render_target.view));
    defer _ = dx.release(texture);

    const texture_desc = dx.getTexture2DDesc(texture);

    return @Vector(2, c_uint){ texture_desc.Width, texture_desc.Height };
}
