const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const dxh = @import("dxh");
pub const IDXGIDevice = dxh.IDXGIDevice;
pub const IDXGIAdapter = dxh.IDXGIAdapter;
pub const DXGI_ADAPTER_DESC = dxh.DXGI_ADAPTER_DESC;
pub const ID3DBlob = dxh.ID3DBlob;
pub const D3D_SHADER_MACRO = dxh.D3D_SHADER_MACRO;
pub const ID3D11DeviceContext = dxh.ID3D11DeviceContext;
pub const ID3D11Device = dxh.ID3D11Device;
pub const ID3D11ShaderResourceView = dxh.ID3D11ShaderResourceView;
pub const D3D11_BLEND_DESC = dxh.D3D11_BLEND_DESC;
pub const D3D11_PRIMITIVE_TOPOLOGY = dxh.D3D11_PRIMITIVE_TOPOLOGY;
pub const D3D11_TEXTURE2D_DESC = dxh.D3D11_TEXTURE2D_DESC;
pub const ID3D11BlendState = dxh.ID3D11BlendState;
pub const ID3D11Resource = dxh.ID3D11Resource;
pub const IDXGISwapChain = dxh.IDXGISwapChain;
pub const DXGI_SWAP_CHAIN_FLAG = dxh.DXGI_SWAP_CHAIN_FLAG;
pub const D3D11_SUBRESOURCE_DATA = dxh.D3D11_SUBRESOURCE_DATA;
pub const ID3D11RenderTargetView = dxh.ID3D11RenderTargetView;
pub const ID3D11PixelShader = dxh.ID3D11PixelShader;
pub const ID3D11VertexShader = dxh.ID3D11VertexShader;
pub const ID3D11Buffer = dxh.ID3D11Buffer;
pub const ID3D11SamplerState = dxh.ID3D11SamplerState;
pub const ID3D11Texture2D = dxh.ID3D11Texture2D;
pub const DXGI_FORMAT_B8G8R8A8_UNORM_SRGB = dxh.DXGI_FORMAT_B8G8R8A8_UNORM_SRGB;
pub const D3D11_VIEWPORT = dxh.D3D11_VIEWPORT;
pub const DXGI_MODE_SCALING_UNSPECIFIED = dxh.DXGI_MODE_SCALING_UNSPECIFIED;
pub const DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED = dxh.DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
pub const D3D11_MAP_WRITE_DISCARD = dxh.D3D11_MAP_WRITE_DISCARD;
pub const TRUE = dxh.TRUE;
pub const FALSE = dxh.FALSE;
pub const DXGI_SWAP_EFFECT_DISCARD = dxh.DXGI_SWAP_EFFECT_DISCARD;
pub const DXGI_USAGE_RENDER_TARGET_OUTPUT = dxh.DXGI_USAGE_RENDER_TARGET_OUTPUT;
pub const D3D_DRIVER_TYPE_HARDWARE = dxh.D3D_DRIVER_TYPE_HARDWARE;
pub const D3D11_USAGE_DYNAMIC = dxh.D3D11_USAGE_DYNAMIC;
pub const D3D11_BIND_CONSTANT_BUFFER = dxh.D3D11_BIND_CONSTANT_BUFFER;
pub const D3D11_CPU_ACCESS_READ = dxh.D3D11_CPU_ACCESS_READ;
pub const D3D11_CPU_ACCESS_WRITE = dxh.D3D11_CPU_ACCESS_WRITE;
pub const D3D11_TEXTURE_ADDRESS_BORDER = dxh.D3D11_TEXTURE_ADDRESS_BORDER;
pub const D3D11_FILTER_MIN_MAG_LINEAR_MIP_POINT = dxh.D3D11_FILTER_MIN_MAG_LINEAR_MIP_POINT;
pub const D3D11_FLOAT32_MAX = dxh.D3D11_FLOAT32_MAX;
pub const D3D11_COMPARISON_ALWAYS = dxh.D3D11_COMPARISON_ALWAYS;
pub const D3D11_RENDER_TARGET_BLEND_DESC = dxh.D3D11_RENDER_TARGET_BLEND_DESC;
pub const D3D11_BLEND_SRC_ALPHA = dxh.D3D11_BLEND_SRC_ALPHA;
pub const D3D11_BLEND_INV_SRC_ALPHA = dxh.D3D11_BLEND_INV_SRC_ALPHA;
pub const D3D11_BLEND_OP_ADD = dxh.D3D11_BLEND_OP_ADD;
pub const D3D11_BLEND_ONE = dxh.D3D11_BLEND_ONE;
pub const D3D11_COLOR_WRITE_ENABLE_ALL = dxh.D3D11_COLOR_WRITE_ENABLE_ALL;
pub const D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST = dxh.D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST;
pub const D3D11_BIND_SHADER_RESOURCE = dxh.D3D11_BIND_SHADER_RESOURCE;
pub const D3D11_USAGE_IMMUTABLE = dxh.D3D11_USAGE_IMMUTABLE;
pub const DXGI_FORMAT_R32_UINT = dxh.DXGI_FORMAT_R32_UINT;
pub const DXGI_FORMAT_R32G32_FLOAT = dxh.DXGI_FORMAT_R32G32_FLOAT;
pub const D3D11_SRV_DIMENSION_BUFFER = dxh.D3D11_SRV_DIMENSION_BUFFER;
pub const DXGI_FORMAT_B8G8R8A8_UNORM = dxh.DXGI_FORMAT_B8G8R8A8_UNORM;
pub const D3D11_USAGE_DEFAULT = dxh.D3D11_USAGE_DEFAULT;
pub const DXGI_FORMAT_R8G8B8A8_UNORM = dxh.DXGI_FORMAT_R8G8B8A8_UNORM;
pub const D3D11_BIND_RENDER_TARGET = dxh.D3D11_BIND_RENDER_TARGET;
pub const D3D11_USAGE_STAGING = dxh.D3D11_USAGE_STAGING;
pub const D3D11_MAP_READ = dxh.D3D11_MAP_READ;
pub const D3D11_CREATE_DEVICE_DEBUG = dxh.D3D11_CREATE_DEVICE_DEBUG;
pub const DXGI_FORMAT_R8G8B8A8_UNORM_SRGB = dxh.DXGI_FORMAT_R8G8B8A8_UNORM_SRGB;

pub fn isInterface(obj: anytype) bool {
    return (@typeInfo(@TypeOf(obj)) == .pointer) and (@typeInfo(std.meta.Child(@TypeOf(obj))) == .@"struct");
}

pub fn isInterfaceType(T: type) bool {
    return (@typeInfo(T) == .@"struct");
}

pub fn release(obj: anytype) c_ulong {
    assert(isInterface(obj));

    return obj.lpVtbl.*.Release.?(obj);
}

pub fn queryInterface(obj: anytype, Interface: type) ?*Interface {
    assert(isInterface(obj));
    assert(comptime isInterfaceType(Interface));

    var interface: ?*Interface = null;

    _ = obj.lpVtbl.*.QueryInterface.?(obj, interfaceId(Interface), @ptrCast(&interface));

    return interface;
}

pub fn getAdapter(dxgi_device: *dxh.IDXGIDevice) Error!*dxh.IDXGIAdapter {
    var adapter: ?*dxh.IDXGIAdapter = null;

    if (errorFromCode(dxgi_device.lpVtbl.*.GetAdapter.?(dxgi_device, &adapter))) |err| return err;

    return adapter.?;
}

pub fn getAdapterDesc(dxgi_adapter: *dxh.IDXGIAdapter) Error!dxh.DXGI_ADAPTER_DESC {
    var dxgi_adapter_desc: dxh.DXGI_ADAPTER_DESC = .{};

    if (errorFromCode(dxgi_adapter.lpVtbl.*.GetDesc.?(dxgi_adapter, &dxgi_adapter_desc))) |err| return err;

    return dxgi_adapter_desc;
}

pub fn getParent(dxgi_object: anytype, Parent: type) Error!*Parent {
    assert(isInterface(dxgi_object));
    assert(comptime isInterfaceType(Parent));

    var parent: ?*Parent = null;

    if (errorFromCode(dxgi_object.lpVtbl.*.GetParent.?(dxgi_object, interfaceId(Parent), @ptrCast(&parent)))) |err| return err;

    return parent.?;
}

pub fn getBufferPointer(blob: *dxh.ID3DBlob) ?[*]u8 {
    return @ptrCast(blob.lpVtbl.*.GetBufferPointer.?(blob));
}

pub fn getBufferSize(blob: *dxh.ID3DBlob) usize {
    return @intCast(blob.lpVtbl.*.GetBufferSize.?(blob));
}

pub fn copyResource(device_context: *ID3D11DeviceContext, dest: *ID3D11Resource, src: *ID3D11Resource) void {
    device_context.lpVtbl.*.CopyResource.?(device_context, dest, src);
}

pub fn getBufferSlice(blob: *dxh.ID3DBlob) ?[]const u8 {
    const buffer_ptr = getBufferPointer(blob) orelse return null;
    const buffer_size = getBufferSize(blob);

    return buffer_ptr[0..buffer_size];
}

pub fn compileShader(
    source: []const u8,
    filename: ?[*:0]const u8,
    defines: ?[]const dxh.D3D_SHADER_MACRO,
    entry_point: [*:0]const u8,
    target: [*:0]const u8,
    errors_blob: ?*?*dxh.ID3DBlob,
) Error!*dxh.ID3DBlob {
    var shader_blob: ?*dxh.ID3DBlob = null;

    if (errorFromCode(dxh.D3DCompile(
        source.ptr,
        source.len,
        filename,
        if (defines) |defs| defs.ptr else null,
        null,
        entry_point,
        target,
        0,
        0,
        &shader_blob,
        errors_blob,
    ))) |err| return err;

    return shader_blob.?;
}

pub fn createVertexShader(device: *dxh.ID3D11Device, bytecode: []const u8) Error!*dxh.ID3D11VertexShader {
    var vertex_shader: ?*dxh.ID3D11VertexShader = null;

    if (errorFromCode(device.lpVtbl.*.CreateVertexShader.?(device, bytecode.ptr, bytecode.len, null, &vertex_shader))) |err| return err;

    return vertex_shader.?;
}

pub fn createPixelShader(device: *dxh.ID3D11Device, bytecode: []const u8) Error!*dxh.ID3D11PixelShader {
    var pixel_shader: ?*dxh.ID3D11PixelShader = null;

    if (errorFromCode(device.lpVtbl.*.CreatePixelShader.?(device, bytecode.ptr, bytecode.len, null, &pixel_shader))) |err| return err;

    return pixel_shader.?;
}

pub fn bindVertexShader(device_context: *dxh.ID3D11DeviceContext, vertex_shader: *dxh.ID3D11VertexShader) void {
    device_context.lpVtbl.*.VSSetShader.?(device_context, vertex_shader, null, 0);
}

pub fn bindPixelShader(device_context: *dxh.ID3D11DeviceContext, pixel_shader: *dxh.ID3D11PixelShader) void {
    device_context.lpVtbl.*.PSSetShader.?(device_context, pixel_shader, null, 0);
}

pub fn setPrimitiveTopology(device_context: *dxh.ID3D11DeviceContext, topology: dxh.D3D11_PRIMITIVE_TOPOLOGY) void {
    device_context.lpVtbl.*.IASetPrimitiveTopology.?(device_context, topology);
}

pub fn createDevice(adapter: ?*dxh.IDXGIAdapter, driver_type: dxh.D3D_DRIVER_TYPE, flags: dxh.D3D11_CREATE_DEVICE_FLAG, feature_levels: []const dxh.D3D_FEATURE_LEVEL, selected_level: ?*dxh.D3D_FEATURE_LEVEL) Error!struct { *dxh.ID3D11Device, *dxh.ID3D11DeviceContext } {
    var device: ?*dxh.ID3D11Device = null;
    var device_context: ?*dxh.ID3D11DeviceContext = null;

    if (errorFromCode(dxh.D3D11CreateDevice(
        adapter,
        driver_type,
        null,
        flags,
        if (feature_levels.len != 0) feature_levels.ptr else null,
        @intCast(feature_levels.len),
        dxh.D3D11_SDK_VERSION,
        &device,
        selected_level,
        &device_context,
    ))) |err| return err;

    errdefer {
        if (device) |d| _ = release(d);
        if (device_context) |dc| _ = release(dc);
    }

    return .{
        device.?,
        device_context.?,
    };
}

pub const IDXGIFactory = extern struct {
    lpVtbl: [*c]IDXGIFactoryVtbl = null,
};

const HWND = ?std.os.windows.HWND;

const IDXGIFactoryVtbl = extern struct {
    QueryInterface: ?*const fn ([*c]IDXGIFactory, [*c]const dxh.IID, [*c]?*anyopaque) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, [*c]const dxh.IID, [*c]?*anyopaque) callconv(.winapi) dxh.HRESULT),
    AddRef: ?*const fn ([*c]IDXGIFactory) callconv(.winapi) dxh.ULONG = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory) callconv(.winapi) dxh.ULONG),
    Release: ?*const fn ([*c]IDXGIFactory) callconv(.winapi) dxh.ULONG = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory) callconv(.winapi) dxh.ULONG),
    SetPrivateData: ?*const fn ([*c]IDXGIFactory, [*c]const dxh.GUID, dxh.UINT, ?*const anyopaque) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, [*c]const dxh.GUID, dxh.UINT, ?*const anyopaque) callconv(.winapi) dxh.HRESULT),
    SetPrivateDataInterface: ?*const fn ([*c]IDXGIFactory, [*c]const dxh.GUID, [*c]const dxh.IUnknown) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, [*c]const dxh.GUID, [*c]const dxh.IUnknown) callconv(.winapi) dxh.HRESULT),
    GetPrivateData: ?*const fn ([*c]IDXGIFactory, [*c]const dxh.GUID, [*c]dxh.UINT, ?*anyopaque) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, [*c]const dxh.GUID, [*c]dxh.UINT, ?*anyopaque) callconv(.winapi) dxh.HRESULT),
    GetParent: ?*const fn ([*c]IDXGIFactory, [*c]const dxh.IID, [*c]?*anyopaque) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, [*c]const dxh.IID, [*c]?*anyopaque) callconv(.winapi) dxh.HRESULT),
    EnumAdapters: ?*const fn ([*c]IDXGIFactory, dxh.UINT, [*c][*c]IDXGIAdapter) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, dxh.UINT, [*c][*c]IDXGIAdapter) callconv(.winapi) dxh.HRESULT),
    MakeWindowAssociation: ?*const fn ([*c]IDXGIFactory, HWND, dxh.UINT) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, HWND, dxh.UINT) callconv(.winapi) dxh.HRESULT),
    GetWindowAssociation: ?*const fn ([*c]IDXGIFactory, [*c]HWND) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, [*c]HWND) callconv(.winapi) dxh.HRESULT),
    CreateSwapChain: ?*const fn ([*c]IDXGIFactory, [*c]dxh.IUnknown, [*c]DXGI_SWAP_CHAIN_DESC, [*c][*c]IDXGISwapChain) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, [*c]dxh.IUnknown, [*c]DXGI_SWAP_CHAIN_DESC, [*c][*c]IDXGISwapChain) callconv(.winapi) dxh.HRESULT),
    CreateSoftwareAdapter: ?*const fn ([*c]IDXGIFactory, dxh.HMODULE, [*c][*c]IDXGIAdapter) callconv(.winapi) dxh.HRESULT = @import("std").mem.zeroes(?*const fn ([*c]IDXGIFactory, dxh.HMODULE, [*c][*c]IDXGIAdapter) callconv(.winapi) dxh.HRESULT),
};

// For whatever reason, `zig translate-c` generates `HWND` type as a pointer to a 4 bytes sized struct.
// This makes the pointer type 4 bytes aligned, which is not suitable for results of `CreateWindowEx(...)` and so on.
pub const DXGI_SWAP_CHAIN_DESC = extern struct {
    BufferDesc: dxh.DXGI_MODE_DESC = @import("std").mem.zeroes(dxh.DXGI_MODE_DESC),
    SampleDesc: dxh.DXGI_SAMPLE_DESC = @import("std").mem.zeroes(dxh.DXGI_SAMPLE_DESC),
    BufferUsage: dxh.DXGI_USAGE = @import("std").mem.zeroes(dxh.DXGI_USAGE),
    BufferCount: dxh.UINT = @import("std").mem.zeroes(dxh.UINT),
    OutputWindow: HWND = @import("std").mem.zeroes(HWND),
    Windowed: dxh.WINBOOL = @import("std").mem.zeroes(dxh.WINBOOL),
    SwapEffect: dxh.DXGI_SWAP_EFFECT = @import("std").mem.zeroes(dxh.DXGI_SWAP_EFFECT),
    Flags: dxh.UINT = @import("std").mem.zeroes(dxh.UINT),
};

pub fn createSwapChain(dxgi_factory: *IDXGIFactory, device: *dxh.ID3D11Device, swap_chain_desc: *DXGI_SWAP_CHAIN_DESC) Error!*dxh.IDXGISwapChain {
    var swap_chain: ?*dxh.IDXGISwapChain = null;

    if (errorFromCode(dxgi_factory.lpVtbl.*.CreateSwapChain.?(dxgi_factory, @ptrCast(device), swap_chain_desc, &swap_chain))) |err| return err;

    return swap_chain.?;
}

pub fn createRenderTargetView(device: *dxh.ID3D11Device, resource: *dxh.ID3D11Resource) Error!*dxh.ID3D11RenderTargetView {
    var render_target_view: ?*dxh.ID3D11RenderTargetView = null;

    if (errorFromCode(device.lpVtbl.*.CreateRenderTargetView.?(device, resource, null, &render_target_view))) |err| return err;

    return render_target_view.?;
}

pub fn getBuffer(swap_chain: *dxh.IDXGISwapChain, index: c_uint, Interface: type) Error!*Interface {
    comptime {
        assert(isInterfaceType(Interface));
    }

    var buffer: ?*Interface = null;

    if (errorFromCode(swap_chain.lpVtbl.*.GetBuffer.?(
        swap_chain,
        index,
        interfaceId(Interface),
        @ptrCast(&buffer),
    ))) |err| return err;

    return buffer.?;
}

pub fn resizeBuffers(swap_chain: *dxh.IDXGISwapChain, flags: dxh.DXGI_SWAP_CHAIN_FLAG) Error!void {
    if (errorFromCode(swap_chain.lpVtbl.*.ResizeBuffers.?(swap_chain, 0, 0, 0, dxh.DXGI_FORMAT_UNKNOWN, flags))) |err| return err;
}

pub fn setRenderTargets(device_context: *dxh.ID3D11DeviceContext, targets: []const *dxh.ID3D11RenderTargetView) void {
    device_context.lpVtbl.*.OMSetRenderTargets.?(
        device_context,
        @intCast(targets.len),
        if (targets.len != 0) targets.ptr else null,
        null,
    );
}

pub fn getRenderTargets(device_context: *dxh.ID3D11DeviceContext, targets: []?*dxh.ID3D11RenderTargetView) void {
    device_context.lpVtbl.*.OMGetRenderTargets.?(
        device_context,
        @intCast(targets.len),
        if (targets.len != 0) targets.ptr else null,
        null,
    );
}

pub fn setViewports(device_context: *dxh.ID3D11DeviceContext, viewports: []const dxh.D3D11_VIEWPORT) void {
    device_context.lpVtbl.*.RSSetViewports.?(
        device_context,
        @intCast(viewports.len),
        if (viewports.len != 0) viewports.ptr else null,
    );
}

pub fn present(swap_chain: *dxh.IDXGISwapChain, sync_interval: c_uint) Error!void {
    if (errorFromCode(swap_chain.lpVtbl.*.Present.?(swap_chain, sync_interval, 0))) |err| return err;
}

pub fn draw(device_context: *dxh.ID3D11DeviceContext, vertex_count: c_uint, start_vertex: c_uint) void {
    device_context.lpVtbl.*.Draw.?(device_context, vertex_count, start_vertex);
}

pub fn createBuffer(device: *dxh.ID3D11Device, desc: *const dxh.D3D11_BUFFER_DESC, initial_data: []const u8) Error!*dxh.ID3D11Buffer {
    var buffer: ?*dxh.ID3D11Buffer = null;

    if (errorFromCode(device.lpVtbl.*.CreateBuffer.?(device, desc, if (initial_data.len != 0) &dxh.D3D11_SUBRESOURCE_DATA{
        .pSysMem = initial_data.ptr,
        .SysMemPitch = 0,
        .SysMemSlicePitch = 0,
    } else null, &buffer))) |err| return err;

    return buffer.?;
}

pub fn setVertexShaderConstantBuffers(device_context: *dxh.ID3D11DeviceContext, slot_offset: c_uint, buffer_count: c_uint, buffers: ?[*]const *dxh.ID3D11Buffer) void {
    device_context.lpVtbl.*.VSSetConstantBuffers.?(
        device_context,
        slot_offset,
        buffer_count,
        buffers,
    );
}

pub fn setPixelShaderConstantBuffers(device_context: *dxh.ID3D11DeviceContext, slot_offset: c_uint, buffer_count: c_uint, buffers: ?[*]const *dxh.ID3D11Buffer) void {
    device_context.lpVtbl.*.PSSetConstantBuffers.?(
        device_context,
        slot_offset,
        buffer_count,
        buffers,
    );
}

pub fn setVertexShaderResources(device_context: *dxh.ID3D11DeviceContext, slot_offset: c_uint, view_count: c_uint, views: ?[*]const *dxh.ID3D11ShaderResourceView) void {
    device_context.lpVtbl.*.VSSetShaderResources.?(
        device_context,
        slot_offset,
        view_count,
        views,
    );
}

pub fn setPixelShaderResources(device_context: *dxh.ID3D11DeviceContext, slot_offset: c_uint, view_count: c_uint, views: ?[*]const *dxh.ID3D11ShaderResourceView) void {
    device_context.lpVtbl.*.PSSetShaderResources.?(
        device_context,
        slot_offset,
        view_count,
        views,
    );
}

pub const raw = struct {
    pub fn map(device_context: *dxh.ID3D11DeviceContext, resource: *dxh.ID3D11Resource, subresource: c_uint, map_type: dxh.D3D11_MAP, flags: dxh.D3D11_MAP_FLAG) Error!dxh.D3D11_MAPPED_SUBRESOURCE {
        var mapped_subresource: dxh.D3D11_MAPPED_SUBRESOURCE = std.mem.zeroes(dxh.D3D11_MAPPED_SUBRESOURCE);

        if (errorFromCode(device_context.lpVtbl.*.Map.?(device_context, resource, subresource, map_type, flags, &mapped_subresource))) |err| return err;

        return mapped_subresource;
    }
};

pub const MapError = Error || error{NullData};

pub fn map(comptime T: type, device_context: *dxh.ID3D11DeviceContext, resource: *dxh.ID3D11Resource, subresource: c_uint, map_type: dxh.D3D11_MAP, flags: dxh.D3D11_MAP_FLAG) MapError!T {
    comptime {
        assert(@typeInfo(T) == .pointer);
    }

    const mapped_subresource = try raw.map(device_context, resource, subresource, map_type, flags);

    if (mapped_subresource.pData) |data| {
        return @alignCast(@ptrCast(data));
    } else {
        unmap(device_context, resource, subresource);
        return error.NullData;
    }
}

pub fn unmap(device_context: *dxh.ID3D11DeviceContext, resource: *dxh.ID3D11Resource, subresource: c_uint) void {
    device_context.lpVtbl.*.Unmap.?(device_context, resource, subresource);
}

pub fn createShaderResourceView(device: *dxh.ID3D11Device, resource: *dxh.ID3D11Resource, desc: ?*const dxh.D3D11_SHADER_RESOURCE_VIEW_DESC) Error!*dxh.ID3D11ShaderResourceView {
    var shader_resource_view: ?*dxh.ID3D11ShaderResourceView = null;

    if (errorFromCode(device.lpVtbl.*.CreateShaderResourceView.?(device, resource, desc, &shader_resource_view))) |err| return err;

    return shader_resource_view.?;
}

pub fn clearRenderTargetView(device_context: *dxh.ID3D11DeviceContext, render_target_view: *dxh.ID3D11RenderTargetView, color: [4]f32) void {
    device_context.lpVtbl.*.ClearRenderTargetView.?(device_context, render_target_view, &color);
}

pub fn getResource(render_target_view: *dxh.ID3D11RenderTargetView) *dxh.ID3D11Resource {
    var resource: ?*dxh.ID3D11Resource = null;

    render_target_view.lpVtbl.*.GetResource.?(render_target_view, &resource);

    return resource.?;
}

pub fn getTexture2DDesc(texture: *dxh.ID3D11Texture2D) dxh.D3D11_TEXTURE2D_DESC {
    var desc: dxh.D3D11_TEXTURE2D_DESC = std.mem.zeroes(dxh.D3D11_TEXTURE2D_DESC);

    texture.lpVtbl.*.GetDesc.?(texture, &desc);

    return desc;
}

pub fn createTexture2D(device: *dxh.ID3D11Device, desc: *const dxh.D3D11_TEXTURE2D_DESC, initial_data: ?*const dxh.D3D11_SUBRESOURCE_DATA) Error!*dxh.ID3D11Texture2D {
    var texture: ?*dxh.ID3D11Texture2D = null;

    if (errorFromCode(device.lpVtbl.*.CreateTexture2D.?(device, desc, initial_data, &texture))) |err| return err;

    return texture.?;
}

pub fn createSamplerState(device: *dxh.ID3D11Device, desc: *const dxh.D3D11_SAMPLER_DESC) Error!*dxh.ID3D11SamplerState {
    var sampler_state: ?*dxh.ID3D11SamplerState = null;

    if (errorFromCode(device.lpVtbl.*.CreateSamplerState.?(device, desc, &sampler_state))) |err| return err;

    return sampler_state.?;
}

pub fn setPixelShaderSamplers(device_context: *dxh.ID3D11DeviceContext, slot_offset: c_uint, sampler_count: c_uint, samplers: ?[*]const *dxh.ID3D11SamplerState) void {
    device_context.lpVtbl.*.PSSetSamplers.?(
        device_context,
        slot_offset,
        sampler_count,
        samplers,
    );
}

pub fn createBlendState(device: *dxh.ID3D11Device, desc: *const dxh.D3D11_BLEND_DESC) Error!*dxh.ID3D11BlendState {
    var blend_state: ?*dxh.ID3D11BlendState = null;

    if (errorFromCode(device.lpVtbl.*.CreateBlendState.?(device, desc, &blend_state))) |err| return err;

    return blend_state.?;
}

pub fn setBlendState(device_context: *dxh.ID3D11DeviceContext, blend_state: *dxh.ID3D11BlendState, blend_factors: ?*const [4]f32, sample_mask: c_uint) void {
    device_context.lpVtbl.*.OMSetBlendState.?(device_context, blend_state, @ptrCast(blend_factors), sample_mask);
}

pub fn interfaceId(Interface: type) *const dxh.IID {
    assert(isInterfaceType(Interface));

    return switch (Interface) {
        dxh.ID3D11DeviceChild => &dxh.IID_ID3D11DeviceChild,
        dxh.ID3D11Asynchronous => &dxh.IID_ID3D11Asynchronous,
        dxh.ID3D11Query => &dxh.IID_ID3D11Query,
        dxh.ID3D11Resource => &dxh.IID_ID3D11Resource,
        dxh.ID3D11View => &dxh.IID_ID3D11View,
        dxh.ID3D11BlendState => &dxh.IID_ID3D11BlendState,
        dxh.ID3D11Buffer => &dxh.IID_ID3D11Buffer,
        dxh.ID3D11ClassInstance => &dxh.IID_ID3D11ClassInstance,
        dxh.ID3D11ClassLinkage => &dxh.IID_ID3D11ClassLinkage,
        dxh.ID3D11CommandList => &dxh.IID_ID3D11CommandList,
        dxh.ID3D11ComputeShader => &dxh.IID_ID3D11ComputeShader,
        dxh.ID3D11Counter => &dxh.IID_ID3D11Counter,
        dxh.ID3D11DepthStencilState => &dxh.IID_ID3D11DepthStencilState,
        dxh.ID3D11DepthStencilView => &dxh.IID_ID3D11DepthStencilView,
        dxh.ID3D11DomainShader => &dxh.IID_ID3D11DomainShader,
        dxh.ID3D11GeometryShader => &dxh.IID_ID3D11GeometryShader,
        dxh.ID3D11HullShader => &dxh.IID_ID3D11HullShader,
        dxh.ID3D11InputLayout => &dxh.IID_ID3D11InputLayout,
        dxh.ID3D11PixelShader => &dxh.IID_ID3D11PixelShader,
        dxh.ID3D11Predicate => &dxh.IID_ID3D11Predicate,
        dxh.ID3D11RasterizerState => &dxh.IID_ID3D11RasterizerState,
        dxh.ID3D11RenderTargetView => &dxh.IID_ID3D11RenderTargetView,
        dxh.ID3D11SamplerState => &dxh.IID_ID3D11SamplerState,
        dxh.ID3D11ShaderResourceView => &dxh.IID_ID3D11ShaderResourceView,
        dxh.ID3D11Texture1D => &dxh.IID_ID3D11Texture1D,
        dxh.ID3D11Texture2D => &dxh.IID_ID3D11Texture2D,
        dxh.ID3D11Texture3D => &dxh.IID_ID3D11Texture3D,
        dxh.ID3D11UnorderedAccessView => &dxh.IID_ID3D11UnorderedAccessView,
        dxh.ID3D11VertexShader => &dxh.IID_ID3D11VertexShader,
        dxh.ID3D11DeviceContext => &dxh.IID_ID3D11DeviceContext,
        dxh.ID3D11AuthenticatedChannel => &dxh.IID_ID3D11AuthenticatedChannel,
        dxh.ID3D11CryptoSession => &dxh.IID_ID3D11CryptoSession,
        dxh.ID3D11VideoDecoder => &dxh.IID_ID3D11VideoDecoder,
        dxh.ID3D11VideoProcessorEnumerator => &dxh.IID_ID3D11VideoProcessorEnumerator,
        dxh.ID3D11VideoProcessor => &dxh.IID_ID3D11VideoProcessor,
        dxh.ID3D11VideoDecoderOutputView => &dxh.IID_ID3D11VideoDecoderOutputView,
        dxh.ID3D11VideoProcessorInputView => &dxh.IID_ID3D11VideoProcessorInputView,
        dxh.ID3D11VideoProcessorOutputView => &dxh.IID_ID3D11VideoProcessorOutputView,
        dxh.ID3D11VideoDevice => &dxh.IID_ID3D11VideoDevice,
        dxh.ID3D11VideoContext => &dxh.IID_ID3D11VideoContext,
        dxh.ID3D11Device => &dxh.IID_ID3D11Device,
        dxh.IDXGIObject => &dxh.IID_IDXGIObject,
        dxh.IDXGIDeviceSubObject => &dxh.IID_IDXGIDeviceSubObject,
        dxh.IDXGIResource => &dxh.IID_IDXGIResource,
        dxh.IDXGIKeyedMutex => &dxh.IID_IDXGIKeyedMutex,
        dxh.IDXGISurface => &dxh.IID_IDXGISurface,
        dxh.IDXGISurface1 => &dxh.IID_IDXGISurface1,
        dxh.IDXGIOutput => &dxh.IID_IDXGIOutput,
        dxh.IDXGIAdapter => &dxh.IID_IDXGIAdapter,
        dxh.IDXGISwapChain => &dxh.IID_IDXGISwapChain,
        IDXGIFactory => &dxh.IID_IDXGIFactory,
        dxh.IDXGIDevice => &dxh.IID_IDXGIDevice,
        else => @compileError("Cannot get DirectX type ID for interface " ++ @typeName(Interface)),
    };
}

pub const ErrorCode = enum(c_ulong) {
    dxgi_access_denied = 0x887A002B,
    dxgi_access_lost = 0x887A0026,
    dxgi_already_exists = 0x887A0036,
    dxgi_cannot_protect_content = 0x887A002A,
    dxgi_device_hung = 0x887A0006,
    dxgi_device_removed = 0x887A0005,
    dxgi_device_reset = 0x887A0007,
    dxgi_driver_internal_error = 0x887A0020,
    dxgi_frame_statistics_disjoint = 0x887A000B,
    dxgi_graphics_vidpn_source_in_use = 0x887A000C,
    dxgi_invalid_call = 0x887A0001,
    dxgi_more_data = 0x887A0003,
    dxgi_name_already_exists = 0x887A002C,
    dxgi_nonexclusive = 0x887A0021,
    dxgi_not_currently_available = 0x887A0022,
    dxgi_not_found = 0x887A0002,
    dxgi_remote_client_disconnected = 0x887A0023,
    dxgi_remote_outofmemory = 0x887A0024,
    dxgi_restrict_to_output_stale = 0x887A0029,
    dxgi_sdk_component_missing = 0x887A002D,
    dxgi_session_disconnected = 0x887A0028,
    dxgi_unsupported = 0x887A0004,
    dxgi_wait_timeout = 0x887A0027,
    dxgi_was_still_drawing = 0x887A000A,
    dxgi_status_occluded = 0x087A0001,
    dxgi_status_mode_changed = 0x087A0007,
    dxgi_status_mode_change_in_progress = 0x087A0008,
    d3d11_file_not_found = 0x887C0002,
    d3d11_too_many_unique_state_objects = 0x887C0001,
    d3d11_too_many_unique_view_objects = 0x887C0003,
    d3d11_deferred_context_map_without_initial_discard = 0x887C0004,
    file_not_found = 2147942403,
    fail = 0x80004005,
    invalid_arg = 0x80070057,
    out_of_memory = 0x8007000E,
    not_implemented = 0x80004001,

    false = 1,
    success = 0,

    _,
};

pub const Error = error{
    Unexpected,
    DXGIAccessDenied,
    DXGIAccessLost,
    DXGIAlreadyExists,
    DXGICannotProtectContent,
    DXGIDeviceHung,
    DXGIDeviceRemoved,
    DXGIDeviceReset,
    DXGIDriverInternalError,
    DXGIFrameStatisticsDisjoint,
    DXGIGraphicsVidpnSourceInUse,
    DXGIInvalidCall,
    DXGIMoreData,
    DXGINameAlreadyExists,
    DXGINonexclusive,
    DXGINotCurrentlyAvailable,
    DXGINotFound,
    DXGIRemoteClientDisconnected,
    DXGIRemoteOutofmemory,
    DXGIRestrictToOutputStale,
    DXGISdkComponentMissing,
    DXGISessionDisconnected,
    DXGIUnsupported,
    DXGIWaitTimeout,
    DXGIWasStillDrawing,
    D3D11FileNotFound,
    D3D11TooManyUniqueStateObjects,
    D3D11TooManyUniqueViewObjects,
    D3D11DeferredContextMapWithoutInitialDiscard,
    DXGIStatusOccluded,
    DXGIStatusModeChanged,
    DXGIStatusModeChangeInProgress,
    FileNotFound,
    Fail,
    InvalidArg,
    OutOfMemory,
    NotImplemented,
    False,
};

pub fn errorFromCode(code: dxh.HRESULT) ?Error {
    return switch (@as(ErrorCode, @enumFromInt(@as(c_ulong, @bitCast(code))))) {
        .dxgi_access_denied => Error.DXGIAccessDenied,
        .dxgi_access_lost => Error.DXGIAccessLost,
        .dxgi_already_exists => Error.DXGIAlreadyExists,
        .dxgi_cannot_protect_content => Error.DXGICannotProtectContent,
        .dxgi_device_hung => Error.DXGIDeviceHung,
        .dxgi_device_removed => Error.DXGIDeviceRemoved,
        .dxgi_device_reset => Error.DXGIDeviceReset,
        .dxgi_driver_internal_error => Error.DXGIDriverInternalError,
        .dxgi_frame_statistics_disjoint => Error.DXGIFrameStatisticsDisjoint,
        .dxgi_graphics_vidpn_source_in_use => Error.DXGIGraphicsVidpnSourceInUse,
        .dxgi_invalid_call => Error.DXGIInvalidCall,
        .dxgi_more_data => Error.DXGIMoreData,
        .dxgi_name_already_exists => Error.DXGINameAlreadyExists,
        .dxgi_nonexclusive => Error.DXGINonexclusive,
        .dxgi_not_currently_available => Error.DXGINotCurrentlyAvailable,
        .dxgi_not_found => Error.DXGINotFound,
        .dxgi_remote_client_disconnected => Error.DXGIRemoteClientDisconnected,
        .dxgi_remote_outofmemory => Error.DXGIRemoteOutofmemory,
        .dxgi_restrict_to_output_stale => Error.DXGIRestrictToOutputStale,
        .dxgi_sdk_component_missing => Error.DXGISdkComponentMissing,
        .dxgi_session_disconnected => Error.DXGISessionDisconnected,
        .dxgi_unsupported => Error.DXGIUnsupported,
        .dxgi_wait_timeout => Error.DXGIWaitTimeout,
        .dxgi_was_still_drawing => Error.DXGIWasStillDrawing,
        .d3d11_file_not_found => Error.D3D11FileNotFound,
        .d3d11_too_many_unique_state_objects => Error.D3D11TooManyUniqueStateObjects,
        .d3d11_too_many_unique_view_objects => Error.D3D11TooManyUniqueViewObjects,
        .d3d11_deferred_context_map_without_initial_discard => Error.D3D11DeferredContextMapWithoutInitialDiscard,
        .file_not_found => Error.FileNotFound,
        .dxgi_status_occluded => Error.DXGIStatusOccluded,
        .dxgi_status_mode_changed => Error.DXGIStatusModeChanged,
        .dxgi_status_mode_change_in_progress => Error.DXGIStatusModeChangeInProgress,
        .fail => Error.Fail,
        .invalid_arg => Error.InvalidArg,
        .out_of_memory => Error.OutOfMemory,
        .not_implemented => Error.NotImplemented,
        .false => Error.False,

        .success => null,
        _ => Error.Unexpected,
    };
}
