const std = @import("std");

const dx = @import("dx.zig");
const Renderer = @import("Renderer.zig");
const RenderTarget = @import("RenderTarget.zig");
const Viewport = @import("Viewport.zig");

// TODO Separate staging texture into its own struct (e.g. `StagingTexture`). User might just want to map a window render target.

render_texture: *dx.ID3D11Texture2D,
render_target: RenderTarget,
size: @Vector(2, u32),

pub fn init(renderer: *const Renderer, size: @Vector(2, u32)) dx.Error!@This() {
    // Create render texture
    const render_texture_desc = dx.D3D11_TEXTURE2D_DESC{
        .ArraySize = 1,
        .MipLevels = 1,
        .SampleDesc = .{ .Count = 1 },
        .Usage = dx.D3D11_USAGE_DEFAULT,
        .Width = size[0],
        .Height = size[1],
        .MiscFlags = 0,
        .Format = dx.DXGI_FORMAT_R8G8B8A8_UNORM,
        .BindFlags = dx.D3D11_BIND_RENDER_TARGET | dx.D3D11_BIND_SHADER_RESOURCE,
        .CPUAccessFlags = 0,
    };
    const render_texture = try dx.createTexture2D(renderer.device, &render_texture_desc, null);

    // Create render target view
    const render_target_view = try dx.createRenderTargetView(renderer.device, @ptrCast(render_texture));

    return @This(){
        .render_texture = render_texture,
        .render_target = RenderTarget{ .view = render_target_view },
        .size = size,
    };
}

pub fn viewport(texture: *const @This()) Viewport {
    return Viewport{ .pos = .{ 0, 0 }, .size = texture.size };
}

pub fn deinit(texture: *const @This()) void {
    _ = texture.render_target.deinit();
    _ = dx.release(texture.render_texture);
}
