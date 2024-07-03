const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const imgui_dep = b.dependency("imgui", .{});
    const imgui = imgui_dep.path("");
    const imgui_include_path = imgui;
    const zig_imgui_backend_include_path = b.path("imgui_backend_headers");

    const cimgui_dep = b.dependency("cimgui", .{});
    const cimgui = cimgui_dep.path("");
    const cimgui_include_path = cimgui;

    // cimgui expects imgui to exist in this specific structure
    // - ./imgui/imgui.h
    // - ./imgui/imgui_internal.h
    //
    // So we can just pull down cimgui as an external dependency, fake that structure here
    const zig_cimgui_headers_path = b.path("cimgui_headers");

    const lib = b.addStaticLibrary(.{
        .name = "imgui",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.linkLibCpp();

    // ImGui files
    lib.addCSourceFiles(.{
        .root = imgui,
        .files = &.{
            "imgui.cpp",
            "imgui_demo.cpp",
            "imgui_draw.cpp",
            "imgui_tables.cpp",
            "imgui_widgets.cpp",
        },
        .flags = &.{"-std=c++11"},
    });
    lib.addIncludePath(imgui_include_path);

    // ImGui enable freetype
    const has_freetype = b.option(bool, "enable_freetype", "Build ImGui with freetype instead of stb_truetype") orelse false;
    if (has_freetype) {
        lib.root_module.addCMacro("IMGUI_ENABLE_FREETYPE", "1");
        lib.root_module.addCMacro("CIMGUI_FREETYPE", "1");

        // HACK: Stop error "use of undeclared identifier 'ImFontAtlasGetBuilderForStbTruetype'" when compiling with Freetype
        lib.root_module.addCMacro("ImFontAtlasGetBuilderForStbTruetype()", "NULL");

        lib.addCSourceFiles(.{
            .root = imgui,
            .files = &.{
                "misc/freetype/imgui_freetype.cpp",
            },
            .flags = &.{"-std=c++11"},
        });
        lib.addIncludePath(imgui.path(b, "misc/freetype"));

        // NOTE(jae): 2024-07-01
        // We add the <ft2build.h> include dependency in the parent build.zig
        // for (freetype_lib.root_module.include_dirs.items) |freetype_include_dir| {
        //     switch (freetype_include_dir) {
        //         .path => |p| imgui_lib.addIncludePath(p),
        //         else => {}, // std.debug.panic("unhandled path from SDL: {s}", .{@tagName(sdl_include_dir)}),
        //     }
        // }
    }

    // ImGui SDL2 backend files
    {
        lib.addCSourceFiles(.{
            .root = imgui,
            .files = &.{
                "backends/imgui_impl_sdl2.cpp",
                "backends/imgui_impl_sdlrenderer2.cpp",
            },
            .flags = &.{"-std=c++11"},
        });
        // NOTE(jae): 2024-07-01
        // We add the <SDL.h> include dependency in the parent build.zig
        // for (sdl_lib.root_module.include_dirs.items) |sdl_include_dir| {
        //     switch (sdl_include_dir) {
        //         .path => |p| imgui_lib.addIncludePath(p),
        //         else => {}, // std.debug.panic("unhandled path from SDL: {s}", .{@tagName(sdl_include_dir)}),
        //     }
        // }
    }

    // cimgui files
    lib.addCSourceFiles(.{
        .root = cimgui,
        .files = &.{
            "cimgui.cpp",
        },
        .flags = &.{"-std=c++11"},
    });
    lib.addIncludePath(cimgui_include_path);
    lib.addIncludePath(zig_cimgui_headers_path);
    lib.root_module.addCMacro("IMGUI_IMPL_API", "extern \"C\""); // export "{imgui-folder}/backends/*.cpp"
    switch (target.result.os.tag) {
        .windows => {
            lib.linkSystemLibrary("imm32");
        },
        else => {},
    }
    b.installArtifact(lib);

    const module = b.addModule("imgui", .{
        .root_source_file = b.path("src/imgui.zig"),
    });
    module.addSystemIncludePath(cimgui_include_path);
    module.addIncludePath(zig_cimgui_headers_path);
    module.addIncludePath(zig_imgui_backend_include_path);
}
