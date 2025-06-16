const std = @import("std");
const Allocator = std.mem.Allocator;

const ghdbg = @import("ghdbg");

const dx = @import("dx.zig");
pub const TransferError = dx.MapError;
const ghcon = @import("root.zig");
const Canvas = ghcon.Canvas;
const Glyph = ghcon.Glyph;
const log = @import("log.zig");
const Renderer = @import("Renderer.zig");
const RenderTarget = @import("RenderTarget.zig");

pub const max_layers = 128;

size: @Vector(2, u32),
///Maximum number of glyphs per layer.
max_size: usize,
layers: []Canvas,

glyphs: []Glyph,
glyphs_gpu_buffer: *dx.ID3D11Buffer,
glyphs_gpu_view: *dx.ID3D11ShaderResourceView,

pub const InitOptions = struct {
    renderer: *const Renderer,
    allocator: Allocator,
    layers: []Canvas,
    size: @Vector(2, u32),
    ///Maximum number of glyphs for one layer.
    max_size: usize = 0,
};

pub const InitError = Allocator.Error || dx.Error;

pub fn init(options: *const InitOptions) InitError!@This() {
    const max_size = if (options.max_size == 0) options.size[0] * options.size[1] else options.max_size;

    ghdbg.assert((options.size[0] * options.size[1]) <= max_size,
        \\LayerStack size is greater than max size.
        \\Size: {} * {} = {}.
        \\Max size: {}.
    , .{
        options.size[0],
        options.size[1],
        options.size[0] * options.size[1],
        max_size,
    });

    ghdbg.assertLessThanOrEql(usize, options.layers.len, max_layers);

    const glyphs_len = max_size * options.layers.len;

    const glyphs: []Glyph = options.allocator.alloc(Glyph, glyphs_len) catch |err| {
        log.err(@src(), "Failed to allocate (maximum {} glyphs per layer * {} layers) = {} glyphs ({} bytes) for a layer stack.", .{
            max_size,
            options.layers.len,
            glyphs_len,
            glyphs_len * @sizeOf(Glyph),
        });

        return err;
    };
    errdefer options.allocator.free(glyphs);

    @memset(glyphs, Glyph.alpha);

    const glyphs_gpu_buffer = try dx.createBuffer(
        options.renderer.device,
        &.{
            .BindFlags = dx.D3D11_BIND_SHADER_RESOURCE,
            .ByteWidth = @intCast(glyphs_len * @sizeOf(Glyph)),
            .CPUAccessFlags = dx.D3D11_CPU_ACCESS_WRITE,
            .MiscFlags = 0,
            .StructureByteStride = 0,
            .Usage = dx.D3D11_USAGE_DYNAMIC,
        },
        &.{},
    );
    errdefer _ = dx.release(glyphs_gpu_buffer);

    const glyphs_gpu_view = try dx.createShaderResourceView(
        options.renderer.device,
        @ptrCast(glyphs_gpu_buffer),
        &.{
            .Format = dx.DXGI_FORMAT_R32_UINT,
            .ViewDimension = dx.D3D11_SRV_DIMENSION_BUFFER,
            .unnamed_0 = .{ .Buffer = .{ .unnamed_1 = .{ .NumElements = @intCast(glyphs.len) } } },
        },
    );
    errdefer _ = dx.release(glyphs_gpu_view);

    for (0..options.layers.len) |i| {
        options.layers[i] = Canvas.fromElements(glyphs[(i * options.size[0] * options.size[1])..((i + 1) * options.size[0] * options.size[1])], options.size);
    }

    return @This(){
        .size = options.size,
        .max_size = max_size,
        .glyphs = glyphs,
        .glyphs_gpu_buffer = glyphs_gpu_buffer,
        .glyphs_gpu_view = glyphs_gpu_view,
        .layers = options.layers,
    };
}

pub fn deinit(stack: *const @This(), allocator: Allocator) void {
    log.info(@src(), "Releasing `LayerStack.glyphs_gpu_view`, reference count: {}", .{dx.release(stack.glyphs_gpu_view)});
    log.info(@src(), "Releasing `LayerStack.glyphs_gpu_buffer`, reference count: {}", .{dx.release(stack.glyphs_gpu_buffer)});
    allocator.free(stack.glyphs);
}

pub fn setSize(stack: *@This(), size: @Vector(2, u32)) void {
    ghdbg.assert((size[0] * size[1]) < stack.max_size);

    for (0..stack.layers.len) |i| {
        stack.layers[i] = Canvas.fromElements(
            stack.glyphs[(i * size[0] * size[1])..((i + 1) * size[0] * size[1])],
            size,
        );
    }

    stack.size = size;
}

pub fn transfer(stack: *const @This(), renderer: *const Renderer) TransferError!void {
    ghdbg.assertLessThanOrEql(usize, stack.layers.len, max_layers);

    const glyphs_gpu = (try dx.map(
        [*]Glyph,
        renderer.device_context,
        @ptrCast(stack.glyphs_gpu_buffer),
        0,
        dx.D3D11_MAP_WRITE_DISCARD,
        0,
    ))[0 .. stack.size[0] * stack.size[1] * stack.layers.len];
    defer dx.unmap(renderer.device_context, @ptrCast(stack.glyphs_gpu_buffer), 0);

    @memcpy(glyphs_gpu, stack.glyphs[0 .. stack.size[0] * stack.size[1] * stack.layers.len]);
}

pub fn aspectRatio(layer_stack: *const @This()) f32 {
    if (layer_stack.size[1] == 0) return 0;

    return @as(f32, @floatFromInt(layer_stack.size[0])) / @as(f32, @floatFromInt(layer_stack.size[1]));
}
