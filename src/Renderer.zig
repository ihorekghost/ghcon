const std = @import("std");
const assert = std.debug.assert;

const dx = @import("dx.zig");
pub const RenderError = dx.MapError;
const FontAtlas = @import("FontAtlas.zig");
const LayerStack = @import("LayerStack.zig");
const log = @import("log.zig");
const RenderTarget = @import("RenderTarget.zig");
const Viewport = @import("Viewport.zig");

const msdf_vertex_shader_bytecode = @embedFile("msdf_vertex.cso");
const msdf_pixel_shader_bytecode = @embedFile("msdf_pixel.cso");
const plain_color_vertex_shader_bytecode = @embedFile("plain_color_vertex.cso");
const plain_color_pixel_shader_bytecode = @embedFile("plain_color_pixel.cso");

// Device, device context and DXGI factory
device: *dx.ID3D11Device,
device_context: *dx.ID3D11DeviceContext,
dxgi_factory: *dx.IDXGIFactory,

// MSDF shaders
msdf_vertex_shader: *dx.ID3D11VertexShader,
msdf_pixel_shader: *dx.ID3D11PixelShader,

// MSDF shaders constant buffer
msdf_shader_parameters: *dx.ID3D11Buffer,

// Plain color shaders
plain_color_vertex_shader: *dx.ID3D11VertexShader,
plain_color_pixel_shader: *dx.ID3D11PixelShader,

// Plain color shaders constant buffer
plain_color_shader_parameters: *dx.ID3D11Buffer,

// MSDF font atlas sampler
font_atlas_sampler: *dx.ID3D11SamplerState,

// Alpha blend state
blend_state: *dx.ID3D11BlendState,

pub const InitError = dx.Error || error{CouldNotGetIDXGIDevice};

pub fn init() InitError!@This() {
    const device: *dx.ID3D11Device, const device_context: *dx.ID3D11DeviceContext = try dx.createDevice(
        null,
        dx.D3D_DRIVER_TYPE_HARDWARE,
        if (@import("builtin").mode == .Debug) dx.D3D11_CREATE_DEVICE_DEBUG else 0,
        &.{},
        null,
    );
    errdefer _ = dx.release(device);
    errdefer _ = dx.release(device_context);

    // Get IDXGIDevice from ID3D11Device
    const dxgi_device: *dx.IDXGIDevice = dx.queryInterface(device, dx.IDXGIDevice) orelse return error.CouldNotGetIDXGIDevice;
    defer _ = dx.release(dxgi_device);

    // Get adapter
    const dxgi_adapter: *dx.IDXGIAdapter = try dx.getAdapter(dxgi_device);
    defer _ = dx.release(dxgi_adapter);

    // Get IDXGIFactory from IDXGIAdapter
    const dxgi_factory: *dx.IDXGIFactory = try dx.getParent(dxgi_adapter, dx.IDXGIFactory);
    errdefer _ = dx.release(dxgi_factory);

    // Log graphics adapter name (description)
    log_adapter_name: {
        const adapter_desc = try dx.getAdapterDesc(dxgi_adapter);

        //Log adapter name (description)
        log.info(@src(), "Adapter name: {}", .{std.unicode.fmtUtf16Le(
            adapter_desc.Description[0 .. std.mem.indexOfPosLinear(u16, &adapter_desc.Description, 0, &.{0}) orelse {
                log.warn(@src(), "Couldn't find null terminator in adapter name", .{});
                break :log_adapter_name;
            }],
        )});
    }

    // Create MSDF shaders
    const msdf_vertex_shader = try dx.createVertexShader(device, msdf_vertex_shader_bytecode);
    errdefer _ = dx.release(msdf_vertex_shader);

    const msdf_pixel_shader = try dx.createPixelShader(device, msdf_pixel_shader_bytecode);
    errdefer _ = dx.release(msdf_pixel_shader);

    // Create plain color shaders
    const plain_color_vertex_shader = try dx.createVertexShader(device, plain_color_vertex_shader_bytecode);
    errdefer _ = dx.release(plain_color_vertex_shader);

    const plain_color_pixel_shader = try dx.createPixelShader(device, plain_color_pixel_shader_bytecode);
    errdefer _ = dx.release(plain_color_pixel_shader);

    const msdf_shader_parameters = try dx.createBuffer(device, &.{
        .Usage = dx.D3D11_USAGE_DYNAMIC,
        .BindFlags = dx.D3D11_BIND_CONSTANT_BUFFER,
        .ByteWidth = @sizeOf(MsdfShaderParameters),
        .CPUAccessFlags = dx.D3D11_CPU_ACCESS_WRITE,
        .MiscFlags = 0,
        .StructureByteStride = 0,
    }, &.{});
    errdefer _ = dx.release(msdf_shader_parameters);

    const plain_color_shader_parameters = try dx.createBuffer(device, &.{
        .Usage = dx.D3D11_USAGE_DYNAMIC,
        .BindFlags = dx.D3D11_BIND_CONSTANT_BUFFER,
        .ByteWidth = @sizeOf(PlainColorShaderParameters),
        .CPUAccessFlags = dx.D3D11_CPU_ACCESS_WRITE,
        .MiscFlags = 0,
        .StructureByteStride = 0,
    }, &.{});
    errdefer _ = dx.release(plain_color_shader_parameters);

    //Create font atlas sampler
    const font_atlas_sampler = try dx.createSamplerState(device, &.{
        .AddressU = dx.D3D11_TEXTURE_ADDRESS_BORDER,
        .AddressV = dx.D3D11_TEXTURE_ADDRESS_BORDER,
        .AddressW = dx.D3D11_TEXTURE_ADDRESS_BORDER,
        .Filter = dx.D3D11_FILTER_MIN_MAG_LINEAR_MIP_POINT,
        .MinLOD = 0,
        .MaxLOD = dx.D3D11_FLOAT32_MAX,
        .MipLODBias = 0,
        .MaxAnisotropy = 1,
        .ComparisonFunc = dx.D3D11_COMPARISON_ALWAYS,
        .BorderColor = [4]f32{ 0, 0, 0, 0 },
    });
    errdefer _ = dx.release(font_atlas_sampler);

    var blend_desc = dx.D3D11_BLEND_DESC{
        .AlphaToCoverageEnable = dx.FALSE,
        .IndependentBlendEnable = dx.FALSE,
        .RenderTarget = [1]dx.D3D11_RENDER_TARGET_BLEND_DESC{.{
            .BlendEnable = dx.TRUE,
            .SrcBlend = dx.D3D11_BLEND_SRC_ALPHA,
            .DestBlend = dx.D3D11_BLEND_INV_SRC_ALPHA,
            .BlendOp = dx.D3D11_BLEND_OP_ADD,
            .SrcBlendAlpha = dx.D3D11_BLEND_ONE,
            .DestBlendAlpha = dx.D3D11_BLEND_INV_SRC_ALPHA,
            .BlendOpAlpha = dx.D3D11_BLEND_OP_ADD,
            .RenderTargetWriteMask = dx.D3D11_COLOR_WRITE_ENABLE_ALL,
        }} ++ std.mem.zeroes([7]dx.D3D11_RENDER_TARGET_BLEND_DESC),
    };

    // Create blend state
    const blend_state = try dx.createBlendState(device, &blend_desc);
    errdefer _ = dx.release(blend_state);

    // Set alpha blending
    dx.setBlendState(device_context, blend_state, null, 0xFFFFFFFF);

    // Set triangle topology
    dx.setPrimitiveTopology(device_context, dx.D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);

    // Bind MSDF constant buffers
    dx.setPixelShaderConstantBuffers(device_context, 0, 1, @ptrCast(&msdf_shader_parameters));
    dx.setVertexShaderConstantBuffers(device_context, 0, 1, @ptrCast(&msdf_shader_parameters));

    // Bind plain color constant buffers
    dx.setPixelShaderConstantBuffers(device_context, 1, 1, @ptrCast(&plain_color_shader_parameters));
    dx.setVertexShaderConstantBuffers(device_context, 1, 1, @ptrCast(&plain_color_shader_parameters));

    // Bind font atlas sampler
    dx.setPixelShaderSamplers(device_context, 0, 1, @ptrCast(&font_atlas_sampler));

    return @This(){
        .device = device,
        .device_context = device_context,
        .dxgi_factory = dxgi_factory,
        .msdf_pixel_shader = msdf_pixel_shader,
        .msdf_vertex_shader = msdf_vertex_shader,
        .msdf_shader_parameters = msdf_shader_parameters,
        .plain_color_vertex_shader = plain_color_vertex_shader,
        .plain_color_pixel_shader = plain_color_pixel_shader,
        .plain_color_shader_parameters = plain_color_shader_parameters,
        .font_atlas_sampler = font_atlas_sampler,
        .blend_state = blend_state,
    };
}

pub const RenderLayerStackOptions = struct {
    render_target: RenderTarget,
    viewport: Viewport,
    font_atlas: *const FontAtlas,
    layer_stack: *const LayerStack,
};

pub const RenderPlainColorOptions = struct {
    render_target: RenderTarget,
    viewport: Viewport,
    color: [4]f32,
};

pub fn renderPlainColor(renderer: *const @This(), options: *const RenderPlainColorOptions) RenderError!void {
    // Bind plain color shaders
    dx.bindVertexShader(renderer.device_context, renderer.plain_color_vertex_shader);
    dx.bindPixelShader(renderer.device_context, renderer.plain_color_pixel_shader);

    //Bind render target
    dx.setRenderTargets(renderer.device_context, @as(*const [1]*dx.ID3D11RenderTargetView, &options.render_target.view));

    //Adjust viewport
    const viewport = dx.D3D11_VIEWPORT{
        .MinDepth = 0.0,
        .MaxDepth = 1.0,
        .TopLeftX = @floatFromInt(options.viewport.pos[0]),
        .TopLeftY = @floatFromInt(options.viewport.pos[1]),
        .Width = @floatFromInt(options.viewport.size[0]),
        .Height = @floatFromInt(options.viewport.size[1]),
    };
    dx.setViewports(renderer.device_context, @as(*const [1]dx.D3D11_VIEWPORT, &viewport));

    // Update plain color shader parameters
    {
        const plain_color_shader_parameters: *PlainColorShaderParameters = try dx.map(
            *PlainColorShaderParameters,
            renderer.device_context,
            @ptrCast(renderer.plain_color_shader_parameters),
            0,
            dx.D3D11_MAP_WRITE_DISCARD,
            0,
        );
        defer dx.unmap(renderer.device_context, @ptrCast(renderer.plain_color_shader_parameters), 0);

        plain_color_shader_parameters.color = options.color;
    }

    // Draw call (fullscreen triangle)
    dx.draw(renderer.device_context, 3, 0);
}

pub fn renderLayerStack(renderer: *const @This(), options: *const RenderLayerStackOptions) RenderError!void {
    //Bind MSDF shaders
    dx.bindVertexShader(renderer.device_context, renderer.msdf_vertex_shader);
    dx.bindPixelShader(renderer.device_context, renderer.msdf_pixel_shader);

    //Bind render target
    dx.setRenderTargets(renderer.device_context, @as(*const [1]*dx.ID3D11RenderTargetView, &options.render_target.view));

    //Bind font atlas
    {
        dx.setPixelShaderResources(renderer.device_context, 0, 1, @ptrCast(&options.font_atlas.texture_view));
        dx.setPixelShaderResources(renderer.device_context, 1, 1, @ptrCast(&options.font_atlas.glyphs_positions));
    }

    //Bind layer stack
    dx.setPixelShaderResources(renderer.device_context, 2, 1, @ptrCast(&options.layer_stack.glyphs_gpu_view));

    //Adjust viewport
    const viewport = dx.D3D11_VIEWPORT{
        .MinDepth = 0.0,
        .MaxDepth = 1.0,
        .TopLeftX = @floatFromInt(options.viewport.pos[0]),
        .TopLeftY = @floatFromInt(options.viewport.pos[1]),
        .Width = @floatFromInt(options.viewport.size[0]),
        .Height = @floatFromInt(options.viewport.size[1]),
    };
    dx.setViewports(renderer.device_context, @as(*const [1]dx.D3D11_VIEWPORT, &viewport));

    //Update MSDF shader parameters
    {
        const msdf_shader_parameters: *MsdfShaderParameters = try dx.map(
            *MsdfShaderParameters,
            renderer.device_context,
            @ptrCast(renderer.msdf_shader_parameters),
            0,
            dx.D3D11_MAP_WRITE_DISCARD,
            0,
        );
        defer dx.unmap(renderer.device_context, @ptrCast(renderer.msdf_shader_parameters), 0);

        msdf_shader_parameters.glyph_size_atlas = options.font_atlas.glyph_size;
        msdf_shader_parameters.size_glyphs = @as(@Vector(2, u32), @intCast(options.layer_stack.size));
        msdf_shader_parameters.screen_range_pixels = @max((viewport.Width / @as(f32, @floatFromInt(options.layer_stack.size[0]))) / options.font_atlas.glyph_size[0] * options.font_atlas.pixel_distance_range, 0.75);
    }

    dx.draw(renderer.device_context, @intCast(3 * options.layer_stack.layers.len), 0);
}

pub fn deinit(renderer: *const @This()) void {
    // Blend state
    log.info(@src(), "Releasing blend state. Reference count: {}", .{dx.release(renderer.blend_state)});

    // Font atlas sampler
    log.info(@src(), "Releasing font atlas sampler. Reference count: {}", .{dx.release(renderer.font_atlas_sampler)});

    // MSDF shaders
    log.info(@src(), "Releasing MSDF shader parameters. Reference count: {}", .{dx.release(renderer.msdf_shader_parameters)});
    log.info(@src(), "Releasing MSDF vertex shader. Reference count: {}", .{dx.release(renderer.msdf_vertex_shader)});
    log.info(@src(), "Releasing MSDF pixel shader. Reference count: {}", .{dx.release(renderer.msdf_pixel_shader)});

    // Plain color shaders
    log.info(@src(), "Releasing plain color shader parameters. Reference count: {}", .{dx.release(renderer.plain_color_shader_parameters)});
    log.info(@src(), "Releasing plain color vertex shader. Reference count: {}", .{dx.release(renderer.plain_color_vertex_shader)});
    log.info(@src(), "Releasing plain color pixel shader. Reference count: {}", .{dx.release(renderer.plain_color_pixel_shader)});

    // DXGI factory, device context and device
    log.info(@src(), "Releasing DXGIFactory. Reference count: {}", .{dx.release(renderer.dxgi_factory)});
    log.info(@src(), "Releasing device context. Reference count: {}", .{dx.release(renderer.device_context)});
    log.info(@src(), "Releasing device. Reference count: {}", .{dx.release(renderer.device)});
}

pub const MsdfShaderParameters = extern struct {
    comptime {
        assert(@sizeOf(@This()) != 0 and (@sizeOf(@This()) % 16) == 0); //Size of `MsdfShaderParameters` must be a multiple of 16 and must not be zero.
    }

    /// Size of each layer, in glyphs
    size_glyphs: [2]u32, // 8 bytes
    /// Size of one glyph in the font atlas, in texture coordinates
    glyph_size_atlas: [2]f32, // 8 bytes
    /// screen_glyph_size / atlas_glyph_size * pixel_range
    screen_range_pixels: f32, // 4 bytes

    unused: [12]u8 = [1]u8{0} ** 12, // 12 bytes

    //8 + 8 + 4 + 12 = 32 bytes
};

pub const PlainColorShaderParameters = extern struct {
    comptime {
        assert(@sizeOf(@This()) != 0 and (@sizeOf(@This()) % 16) == 0); //Size of `PlainColorShaderParameters` must be a multiple of 16 and must not be zero.
    }

    color: [4]f32, // 4 * 4 = 16 bytes
};
