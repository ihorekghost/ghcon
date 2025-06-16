const std = @import("std");
const builtin = @import("builtin");

const log = std.log.scoped(.ghcon);

const ShaderKind = enum {
    vertex,
    pixel,

    pub fn profile(shader_kind: @This()) []const u8 {
        return switch (shader_kind) {
            .vertex => "vs_5_0",
            .pixel => "ps_5_0",
        };
    }

    pub fn entryPoint(shader_kind: @This()) []const u8 {
        return switch (shader_kind) {
            .vertex => "MainVS",
            .pixel => "MainPS",
        };
    }
};

fn compileShader(
    b: *std.Build,
    fxc_path: []const u8,
    cache_output_path: []const u8,
    hlsl_source: std.Build.LazyPath,
    kind: ShaderKind,
) std.Build.LazyPath {
    const fxc_cmd = b.addSystemCommand(&.{fxc_path});
    fxc_cmd.addArgs(&.{ "/T", kind.profile(), "/E", kind.entryPoint(), "/Fo" });
    const bytecode = fxc_cmd.addOutputFileArg(cache_output_path);
    fxc_cmd.addFileArg(hlsl_source);

    return bytecode;
}

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    // Expose ghcon module
    const ghcon = b.addModule("ghcon", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    ghcon.link_libc = true;

    // Dependencies
    {
        const ghwin = b.dependency("ghwin", .{
            .target = target,
            .optimize = optimize,
        });
        const ghgrid = b.dependency("ghgrid", .{
            .target = target,
            .optimize = optimize,
        });
        const ghmath = b.dependency("ghmath", .{
            .target = target,
            .optimize = optimize,
        });
        const ghdbg = b.dependency("ghdbg", .{
            .target = target,
            .optimize = optimize,
        });
        const zigimg = b.dependency("zigimg", .{
            .target = target,
            .optimize = optimize,
        });

        ghcon.addImport("ghwin", ghwin.module("ghwin"));
        ghcon.addImport("ghgrid", ghgrid.module("ghgrid"));
        ghcon.addImport("ghmath", ghmath.module("ghmath"));
        ghcon.addImport("ghdbg", ghdbg.module("ghdbg"));
        ghcon.addImport("zigimg", zigimg.module("zigimg"));
    }

    // Link system libraries
    {
        ghcon.linkSystemLibrary("dxgi", .{});
        ghcon.linkSystemLibrary("d3d11", .{});
        ghcon.linkSystemLibrary("Xinput9_1_0", .{});
    }

    // Translate DirectX (d3d11.h and dxgi.h)
    {
        const translate_dx = b.addTranslateC(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/c/dx.h"),
        });

        ghcon.addImport("dxh", translate_dx.createModule());
    }

    // Add cascadia mono font .png and .json files imports
    ghcon.addAnonymousImport("cascadia_code_json", .{ .root_source_file = b.path("third_party/cascadia-code/CascadiaMono.json") });
    ghcon.addAnonymousImport("cascadia_code_png", .{ .root_source_file = b.path("third_party/cascadia-code/CascadiaMono.png") });

    // Msdf-atlas-gen tool
    msdf_atlas_gen_tool: {
        const atlas_gen_step = b.step("atlas_gen", "Generate .png font atlas and .json metrics data using msdf-atlas-gen");

        const msdf_atlas_gen_path = b.option(
            []const u8,
            "msdf_atlas_gen_path",
            "Path to msdf-atlas-gen executable. Default: \"msdf-atlas-gen\"",
        ) orelse "msdf-atlas-gen";

        const font_size = b.option(
            u16,
            "font_size",
            "Size of glyph in font atlas generated with msdf-atlas-gen",
        ) orelse 16;

        const font_path = b.option(
            []const u8,
            "font_path",
            "Path of a font that is used to generate .png and .json files with msdf-atlas-gen. Without file extension(!)",
        );

        if (font_path == null) {
            atlas_gen_step.dependOn(&b.addFail("`atlas_gen` step requires `font_path` build option.").step);
            break :msdf_atlas_gen_tool;
        }

        const msdf_atlas_gen_cmd = b.addSystemCommand(&.{msdf_atlas_gen_path});

        msdf_atlas_gen_cmd.addArgs(&.{
            "-font",
            b.fmt("{s}.ttf", .{font_path.?}),
            "-size",
            b.fmt("{}", .{font_size}),
            "-type",
            "msdf",
            "-yorigin",
            "top",
            "-imageout",
            b.fmt("{s}.png", .{font_path.?}),
            "-json",
            b.fmt("{s}.json", .{font_path.?}),
            "-charset",
            "assets/charset.txt",
            "-uniformgrid",
            "-uniformorigin",
            "on",
            "-pxalign",
            "on",
            "-outerpxpadding",
            "4",
        });

        atlas_gen_step.dependOn(&msdf_atlas_gen_cmd.step);
    }

    // Get shaders' bytecode
    {
        // Shader compiler path
        const optional_fxc_path = b.option([]const u8, "fxc_path", "Path to fxc shader compiler");

        // Install shaders step
        const install_shaders_step = b.step("install_shaders", "Update shader bytecode at assets/shaders/bin/");

        const msdf_vertex_bytecode, const msdf_pixel_bytecode, const plain_color_vertex_bytecode, const plain_color_pixel_bytecode =
            if (optional_fxc_path) |fxc_path| compile_shaders_blk: {
                const msdf_vertex_bytecode = compileShader(b, fxc_path, "assets/shaders/bin/msdf_vertex.cso", b.path("assets/shaders/hlsl/msdf_vertex.hlsl"), .vertex);
                const msdf_pixel_bytecode = compileShader(b, fxc_path, "assets/shaders/bin/msdf_pixel.cso", b.path("assets/shaders/hlsl/msdf_pixel.hlsl"), .pixel);
                const plain_color_vertex_bytecode = compileShader(b, fxc_path, "assets/shaders/bin/plain_color_vertex.cso", b.path("assets/shaders/hlsl/plain_color_vertex.hlsl"), .vertex);
                const plain_color_pixel_bytecode = compileShader(b, fxc_path, "assets/shaders/bin/plain_color_pixel.cso", b.path("assets/shaders/hlsl/plain_color_pixel.hlsl"), .pixel);

                const update_shaders_bytecode = b.addUpdateSourceFiles();

                update_shaders_bytecode.addCopyFileToSource(msdf_vertex_bytecode, "assets/shaders/bin/msdf_vertex.cso");
                update_shaders_bytecode.addCopyFileToSource(msdf_pixel_bytecode, "assets/shaders/bin/msdf_pixel.cso");
                update_shaders_bytecode.addCopyFileToSource(plain_color_vertex_bytecode, "assets/shaders/bin/plain_color_vertex.cso");
                update_shaders_bytecode.addCopyFileToSource(plain_color_pixel_bytecode, "assets/shaders/bin/plain_color_pixel.cso");

                install_shaders_step.dependOn(&update_shaders_bytecode.step);

                break :compile_shaders_blk .{
                    msdf_vertex_bytecode,
                    msdf_pixel_bytecode,
                    plain_color_vertex_bytecode,
                    plain_color_pixel_bytecode,
                };
            } else load_shaders_bytecode_blk: {
                install_shaders_step.dependOn(&b.addFail("install_shaders step requires fxc_path build option").step);

                break :load_shaders_bytecode_blk .{
                    b.path("assets/shaders/bin/msdf_vertex.cso"),
                    b.path("assets/shaders/bin/msdf_pixel.cso"),
                    b.path("assets/shaders/bin/plain_color_vertex.cso"),
                    b.path("assets/shaders/bin/plain_color_pixel.cso"),
                };
            };

        // Import shaders bytecode
        ghcon.addAnonymousImport("msdf_vertex.cso", .{ .root_source_file = msdf_vertex_bytecode });
        ghcon.addAnonymousImport("msdf_pixel.cso", .{ .root_source_file = msdf_pixel_bytecode });
        ghcon.addAnonymousImport("plain_color_vertex.cso", .{ .root_source_file = plain_color_vertex_bytecode });
        ghcon.addAnonymousImport("plain_color_pixel.cso", .{ .root_source_file = plain_color_pixel_bytecode });
    }
}
