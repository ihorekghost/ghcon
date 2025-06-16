const std = @import("std");
const builtin = @import("builtin");

const ghdbg = @import("ghdbg");
const ghmath = @import("ghmath");
const zigimg = @import("zigimg");

const dx = @import("dx.zig");
const log = @import("log.zig");
const Metrics = @import("FontAtlasMetrics.zig");
const Renderer = @import("Renderer.zig");

pub const cascadia_code_png = @embedFile("cascadia_code_png");

texture_view: *dx.ID3D11ShaderResourceView,
glyphs_positions: *dx.ID3D11ShaderResourceView,
pixel_distance_range: f32,
glyph_size: ghmath.Vec2f32,

const InitError = error{ InvalidImageFormat, RowSizeTooBig } || dx.Error;
pub fn fromImage(renderer: *const Renderer, image: *const zigimg.ImageUnmanaged, metrics: *const Metrics) InitError!@This() {
    if (image.pixelFormat() != .bgra32 and image.pixelFormat() != .rgba32) {
        log.err(@src(), "Insupported image format. Expected `.bgra32` or `.rgba32`, found {}.", .{image.pixelFormat()});
        return InitError.InvalidImageFormat;
    }

    //Allocate glyphs positions buffer on GPU
    const glyphs_positions_buffer = try dx.createBuffer(
        renderer.device,
        &.{
            .BindFlags = dx.D3D11_BIND_SHADER_RESOURCE,
            .ByteWidth = @sizeOf(@TypeOf(metrics.glyphs_positions)),
            .Usage = dx.D3D11_USAGE_IMMUTABLE,
        },
        std.mem.sliceAsBytes(&metrics.glyphs_positions),
    );
    defer _ = dx.release(glyphs_positions_buffer);

    const glyphs_positions_view = try dx.createShaderResourceView(renderer.device, @ptrCast(glyphs_positions_buffer), &.{
        .Format = dx.DXGI_FORMAT_R32G32_FLOAT,
        .ViewDimension = dx.D3D11_SRV_DIMENSION_BUFFER,
        .unnamed_0 = .{ .Buffer = .{ .unnamed_1 = .{ .NumElements = metrics.glyphs_positions.len } } },
    });
    errdefer _ = dx.release(glyphs_positions_view);

    //Allocate font atlas texture on the GPU
    const texture = try dx.createTexture2D(
        renderer.device,
        &.{
            .Format = switch (image.pixelFormat()) {
                .bgra32 => dx.DXGI_FORMAT_B8G8R8A8_UNORM,
                .rgba32 => dx.DXGI_FORMAT_R8G8B8A8_UNORM,
                else => unreachable,
            },

            .ArraySize = 1,
            .BindFlags = dx.D3D11_BIND_SHADER_RESOURCE,
            .CPUAccessFlags = 0,
            .Usage = dx.D3D11_USAGE_IMMUTABLE,
            .Width = @intCast(image.width),
            .Height = @intCast(image.height),
            .MipLevels = 1,
            .MiscFlags = 0,
            .SampleDesc = .{
                .Count = 1,
                .Quality = 0,
            },
        },
        &.{
            .pSysMem = image.rawBytes().ptr,
            .SysMemPitch = std.math.cast(c_uint, image.rowByteSize()) orelse {
                log.err(@src(), "Image row size is too big. Row size: {}", .{image.rowByteSize()});
                return InitError.RowSizeTooBig;
            },
            .SysMemSlicePitch = 0,
        },
    );
    defer _ = dx.release(texture);

    const texture_view = try dx.createShaderResourceView(renderer.device, @ptrCast(texture), null);
    errdefer _ = dx.release(texture_view);

    return @This(){
        .texture_view = texture_view,
        .glyphs_positions = glyphs_positions_view,
        .pixel_distance_range = metrics.pixel_distance_range,
        .glyph_size = metrics.glyph_size,
    };
}

pub const InitFromMemoryError = error{RowSizeTooBig} || zigimg.ImageUnmanaged.ReadError || zigimg.ImageUnmanaged.Error || zigimg.ImageUnmanaged.ConvertError || dx.Error;
pub fn fromMemory(allocator: std.mem.Allocator, renderer: *const Renderer, image_buf: []const u8, metrics: *const Metrics) InitFromMemoryError!@This() {
    var image = try zigimg.ImageUnmanaged.fromMemory(allocator, image_buf);
    defer image.deinit(allocator);

    try image.convert(allocator, .rgba32);

    return fromImage(renderer, &image, metrics) catch |err|
        switch (err) {
            InitError.InvalidImageFormat => unreachable,
            else => @as(InitFromMemoryError, @errorCast(err)),
        };
}

pub fn deinit(font: *const @This()) void {
    _ = dx.release(font.glyphs_positions);
    _ = dx.release(font.texture_view);
}
